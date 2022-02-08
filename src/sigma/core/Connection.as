package sigma.core
{
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.*;
	
	import mx.logging.*;

	public class Connection extends EventDispatcher
	{
		private var _connectionString:String;
		private var _state:ConnectionState;
		private var _stateMessage:String = "";
		private var PROTOCOL_VERSION:int = 1;
		private var _stream:Stream;
		private var _host:String;
		private var _failoverServers:Array;
		private var _currentFailover:int;
		public var conflation:int;
		private var _dictionaries:flash.utils.Dictionary;
		private static var _log:ILogger = Log.getLogger("sigma.core.Connection");
		
		private var _requests:Array;
		private var nextRequestId:int;
		
		private var _serverApplication:String;
		private var _serverVersion:int;
		private var _timer:Timer = null;
		private var _maxConnectingRetries:int = 100 ;
		private var _numOfConnectingRetries:int = 0;
		
		
		public function Connection(connString:String = "")
		{
			PROTOCOL_VERSION = 1;
			_connectionString = _host =  connString ;
			_state = ConnectionState.Disconnected;
			_stateMessage = "";
			conflation = 0;
			nextRequestId = 1;
			
			_requests = new Array();
			_dictionaries = new flash.utils.Dictionary();
			
			_stream = new Stream();
			_stream.addEventListener(StreamEvent.CONNECT, onStreamConnected);
			_stream.addEventListener(StreamEvent.DISCONNECT, onStreamDisconnected);
			_stream.addEventListener(StreamEvent.RECONNECT , onStreamReconnect );
			_stream.addEventListener(StreamEvent.TIME_OUT, onStreamTimeOut);
			_stream.addEventListener(StreamEvent.CONTINUED, onStreamContinued);
			_stream.addEventListener(StreamEvent.MESSAGE, onStreamMessage);
			
			_timer = new Timer(5 * 1000, 1);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.stop();
			
		}
		
		public function send(param1:Message) : Boolean 
		{
			if (param1 == null || _state == ConnectionState.Disconnected )
			{
				return false;
			}			
			_stream.send(param1);			
			return true;
		}
		
		public function set connectionString(param1:String) : void 
		{			
			if (param1 == null && param1 != "" )
			{
				param1 = "localhost";
			}
			if (_connectionString == param1)
			{
				return ;
			}
			_connectionString = param1 ;
			_failoverServers = _connectionString.split(RegExp("[;,]"));
			_currentFailover = 0;
			connect();
			return;
		}
		
		public function openRequest(param1:Message, param2:IRequestEvents) : int 
		{
			var reqId:int = 0;
			
			if (!param2)
			{
				return -1;
			}
			reqId = nextRequestId++ ;
			var req:RequestHandler = new RequestHandler(reqId, param1, param2, this);
			_requests[reqId] = req;
			
			if (_state == ConnectionState.Connected)
			{
				req.open();
			}
			
			return reqId;
		}// end function
		
		public function closeRequest(param1:int) : void 
		{
			var _loc_2:RequestHandler = null;
			_loc_2 = RequestHandler(_requests[param1]);
			if (!_loc_2)
			{
				return;
			}
			_loc_2.close();
			_requests[param1] = null;
			return;
		}// end function
		
		public function get host() : String 
		{
			return _host;
		}
		
		public function get statusMessage() : String 
		{
			return _stateMessage;
		}
		
		public function get status():ConnectionState
		{
			return _state;
		}
		
		public function set connnectionTimeOut(val:int):void
		{
			_stream.connectionTimeOut = val ;
		}
		
		private function setState(newState:ConnectionState, stateMsg:String) : void 
		{
			var _lastState:ConnectionState = null;
			var reqHandler:RequestHandler = null;
			
			if (newState == _state)
			{
				return;
			}
			
			_lastState = _state;
			_state = newState;
			_stateMessage = stateMsg;
			dispatchEvent(new ConnectionStateEvent(ConnectionStateEvent.STATE, newState, stateMsg));
			
			if (_lastState == ConnectionState.Connected)
			{
				for each (reqHandler in _requests )
				{					
					if (reqHandler != null)
					{
						reqHandler.onDisconnected();
					}
				}
			}
			return;
		}
		
		private function onStreamConnected(event:StreamEvent) : void 
		{
			var reqHandler:RequestHandler = null;			
			setState(ConnectionState.Connected, "");
			
			for each (reqHandler in _requests)
			{				
				if (reqHandler != null)
				{
					reqHandler.open();
				}
			}
			return;
		}
		
		private function onStreamDisconnected(event:StreamEvent) : void 
		{
			//_requests = new Array();			
			//_dictionaries = new flash.utils.Dictionary();
			setState(ConnectionState.Disconnected, "");
			//nextRequestId = 1;
			startTimer();
		}
		
		private function onStreamTimeOut(event:StreamEvent) : void 
		{
			//setState(ConnectionState.TimeOut, "");
			dispatchEvent(new ConnectionStateEvent(ConnectionStateEvent.STATE, ConnectionState.TimeOut, ""));
		}
		
		private function onStreamContinued(event:StreamEvent) : void
		{
			//setState(ConnectionState.Continued, "");
			dispatchEvent(new ConnectionStateEvent(ConnectionStateEvent.STATE, ConnectionState.Continued, ""));
		}
		
		private function onStreamReconnect(evt:StreamEvent):void
		{
			setState(ConnectionState.Connecting,"");
		}
		
		private function startTimer() : void 
		{
			if (_timer.running)
			{
				return;
			}
			_timer.reset();
			_timer.start();
			return;
		}
		
		private function onTimer(event:TimerEvent) : void 
		{
			_timer.stop();
			
			if(_numOfConnectingRetries >= _maxConnectingRetries)return ;
			_numOfConnectingRetries++ ;
			
			
			if (_state != ConnectionState.Connected)
			{				
				setState(ConnectionState.Connecting, "Retrying");
				_stream.connect();				
			}			
		}
		
		private function onStreamMessage(event:StreamEvent) : void 
		{
			var msg:Message = null;
			var reqTag:int = 0;
			var rq:RequestHandler = null;
			msg = event.message;
			if (!msg)
			{
				return;
			}
			reqTag = msg.getIntByKey(DataKey.Tag, -1);
			rq = _requests[reqTag];
			if (rq)
			{
				rq.onMessage(msg);
			}
			else{
				switch(msg.type)
				{
					case MessageType.Login:
					{
						_serverVersion = msg.getIntByKey(DataKey.Protocol, -1);
						_serverApplication = msg.getStringByKey(DataKey.Application, "unknown");
						_log.debug("login complete: serverVersion=" + _serverVersion + " serverApplication=\'" + _serverApplication + "\'");
						break;
					}
					default:
					{
						break;
					}
					case MessageType.Status:
					{
						break;
					}
						
				}
			}
		}
		
		public function getDictionary(source:String) : sigma.core.Dictionary 
		{
			var dic:sigma.core.Dictionary = null;
			dic = _dictionaries[source];
			
			if (!dic)
			{
				_log.debug("preparing dictionary request for " + source);
				dic = new sigma.core.Dictionary();
				_dictionaries[source] = dic ;
				dic.connection = this;
				dic.source = source;
				dic.subscribe();
			}
			return dic;
		}// end function
		
		public function connect() : void 
		{
			softDisconnect();
			setState(ConnectionState.Connecting, "");
			_stream.server = _host;
			_stream.connect();
			return;
		}
		
		public function disconnect() : void 
		{
			_requests = new Array();			
			_dictionaries = new flash.utils.Dictionary();
			softDisconnect();
			return;
		}
		
		private function softDisconnect() : void 
		{				
			stopTimer();
			_stream.disconnect();			
			setState(ConnectionState.Disconnected, "");			
		}
		
		private function stopTimer():void
		{
			if (!_timer.running)
			{
				return;
			}
			_timer.stop();
			return;		
		}
	}
}