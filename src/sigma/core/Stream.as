package sigma.core
{
	import com.adobe.serialization.json.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;	
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.utils.Timer;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	//import sigma.data.user.Data;
	
	
	public class Stream extends EventDispatcher
	{
		public var server:String = "";
		private var streamLoader:URLStream = null;
		private var streamRequest:URLRequest = null;
		private var connectionId:String = "" ;
		private var encoder:String;
		private var sendQueue:Array;
		private var nextSendSeq:int;
		private var nextRecvSeq:int;
		
		private var state:int;
		private var receivedStreamedData:String;
		private var lostStreamedData:String ;
		private var _disconnectTimer:Timer = null;
		private var _pollDelayTimer:Timer = null;
		private var _pollDelayTimerForHttp:Timer = null;
		private var _pollDelay:int = 2;
		private var _sendTimer:Timer = null ;		
		
		
		private var cmdService:HTTPService = null;
		private var stmService:HTTPService = null;
		
		private var STATE_CONNECTING:int = 1;
		private var STATE_CONNECTED:int = 2;
		private var STATE_DISCONNECTED:int = 0;
		private var STATE_CONNECTION_TIME_OUT:int = 3;
		private var STATE_CONTINUED:int = 4;
		
		private var streamMode:int;
		private var missedBeats:int;
		private var cfgMaxMissedBeats:int;
		private var cfgHeartInterval:int;
		private var cfgStreamTimeout:int;
		private var stmHeartTimer:Timer;
		private var MODE_UNKNOWN:int = 0;
		private var MODE_STREAMING:int = 2;
		private var MODE_NONSTREAMING:int = 3;
		private var _connected:Boolean = false ;
		
		private var _lastMessageId:String = null;
		private var _messageId:String = null ;
		private var _messages:String = "" ;
		private var _delay:int = 0 ;
		private var _groups:String = null ;
		
		
		private var _connectionTimeOutTimer:Timer = null;
		private var _missedCount:int = 0;
		private var _timeOut:int ;
		
		public function Stream()
		{
			server = "";
			receivedStreamedData = "";
			lostStreamedData = "";
			
			stmService = null;
			cmdService = null;
			streamLoader = null;
			streamRequest = null;
			
			
			STATE_DISCONNECTED = 0;
			STATE_CONNECTING = 1;
			STATE_CONNECTED = 2;
			STATE_CONNECTION_TIME_OUT = 3;
			STATE_CONTINUED = 4;
			
			MODE_UNKNOWN = 0;
			MODE_STREAMING = 2;
			MODE_NONSTREAMING = 3;
			cfgHeartInterval = 5 ;
			cfgMaxMissedBeats = 2;			
			cfgStreamTimeout = 10;
			missedBeats = 0;
			
			
			resetState();
		}
		
		private function cancelStreamRequest() : void 
		{
			if (stmService)
			{
				stmService.cancel();
				stmService = null;
			}
			if (streamLoader)
			{
				streamLoader.close();
				streamLoader = null;
			}
			
			if (stmHeartTimer)
			{
				stmHeartTimer.reset();
				stmHeartTimer = null;
			}
		}
		
		private function cancelCmdRequest() : void 
		{
			if (cmdService)
			{
				cmdService.cancel();
				cmdService = null;
			}			
		}
		
		private function resetState() : void 
		{
			state = STATE_DISCONNECTED;			
			connectionId = "";
			nextSendSeq = 1;
			nextRecvSeq = 1;
			missedBeats = 0;
			streamMode = MODE_UNKNOWN;
			sendQueue = [];
			encoder = "";
			receivedStreamedData = "";
			lostStreamedData = "";	
			_messageId = "0";
			
			_sendTimer = new Timer(300,1);
			_sendTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onSendTimer);
			
			
			_missedCount = 0;
			//_timeOut = 10;
			_connectionTimeOutTimer = new Timer(1000);
			_connectionTimeOutTimer.addEventListener(TimerEvent.TIMER, onConnectionTimedOut);
		}
		
		public function disconnect() : void 
		{
			_connectionTimeOutTimer.reset();
			resetState();
			cancelCmdRequest();
			cancelStreamRequest();			
		}
		
		private function startHeartTimer() : void 
		{
			var t:int = 0;
			if (stmHeartTimer)
			{
				// trace("cancelling existing hearbeat timer");
				stmHeartTimer.reset();
			}
			t = cfgHeartInterval;
			if (streamMode == MODE_UNKNOWN)
			{
				t = cfgStreamTimeout;
			}
			trace("starting hearbeat timer: " + t * 1000 + " ms");
			stmHeartTimer = new Timer(t * 1000, 1);
			stmHeartTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onHeartTimer);
			stmHeartTimer.start();
			return;
		}
		
		private function onHeartTimer(event:TimerEvent) : void 
		{
			if (streamMode == MODE_UNKNOWN)
			{
				trace("Detected non-streaming connection");
				streamMode = MODE_NONSTREAMING;
				cancelStreamRequest();
				//sendNextRequest(); 8/3/2015
				//startPollDelayTimer();
				startPollDelayTimerFotHttp();
				return;
			}
			
			if (streamMode == MODE_STREAMING)
			{
				if (++missedBeats == cfgMaxMissedBeats)
				{
					trace("Missed " + cfgMaxMissedBeats + " heartbeats");
					dropConnection();
				}
			}
			return;
		}
		
		public function connect() : void 
		{			
			disconnect();			
			sendOpenRequest();
			state = STATE_CONNECTING;	
			//if(streamMode == MODE_NONSTREAMING)
			_connectionTimeOutTimer.start();
		}
		
		public function send(param1:Message) : Boolean 
		{
			if (state == STATE_DISCONNECTED)
			{
				return false;
			}
			sendQueue.push(param1);
			sendFlush();
			return true;
		}
		
		private function buildCmdBody() : String 
		{
			var msg:Message = null;
			sendQueue.sortOn("tagIndex", Array.NUMERIC); 
			if (sendQueue.length > 0)
			{
				encoder = encoder + "q(";
				encoder = encoder + nextSendSeq++;
				encoder = encoder + ");\n";
			}
			for each ( msg in sendQueue){
				
				encoder = encoder + "m(";
				encoder = encoder + msg.encode();
				encoder = encoder + ");\n";
			}
			sendQueue = [];
			return encoder;
		}
		
		private function sendOpenRequest() : void 
		{
			createStreamRequest();
			_connected = false;
			streamRequest.url = "http://" + server + "/signalr/negotiate?client=FLEX&prfx"+randomRange(0,10000);
			streamRequest.data = buildCmdBody();
			streamLoader.load(streamRequest);			
			return;
		}
		
		private function randomRange(minNum:Number, maxNum:Number):Number 
		{
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}
		
		private function createStreamRequest() : void 
		{
			if (streamLoader != null)
			{				
				streamLoader.close();
				streamLoader = null;
				_connected = true;			
			}			
			streamLoader = new URLStream();
			streamLoader.addEventListener(Event.OPEN, onStreamOpen, false, 1, true);
			streamLoader.addEventListener(Event.COMPLETE, onStreamComplete, false, 0, true);
			streamLoader.addEventListener(ProgressEvent.PROGRESS, onStreamProgress, false, 0, true);
			streamLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onStreamHttpStatus, false, 0, true);
			streamLoader.addEventListener(IOErrorEvent.IO_ERROR, onStreamIOError, false, 0, true);
			streamLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onStreamSecurityError, false, 0, true);			
			streamRequest = new URLRequest("http://" + server + "/signalr/connect?transport=serverSentEvents&connectionId=" + connectionId + "&stream=1&connectionData=[{'name':'Stream'}]&client=FLEX");
			streamRequest.contentType = "text/plain; charset=UTF-8";
			streamRequest.method = URLRequestMethod.GET;
			
			if(_connected && sendQueue.length > 0 )
			{
				_sendTimer.start();
				//sendFlush();
			}
			
		}
		
		private function sendNextRequest() : void 
		{			
			createStreamRequest();
			if (_messageId == "0" && streamMode == MODE_NONSTREAMING)
			{
				//streamRequest.url = "http://" + server + "/signalR/?transport=serverSentEvents&connectionId=" + connectionId + "&messageId=0&connectionData=[{\"name\":\"Stream\"}]&client=FLEX&prfx"+randomRange(0,10000);
			}
			else if (_messageId != null && streamMode == MODE_NONSTREAMING)
			{
				//streamRequest.url = "http://" + server + "/signalR/?transport=serverSentEvents&connectionId=" + connectionId + "&messageId="+_messageId+"&connectionData=[{\"name\":\"Stream\"}]&client=FLEX&prfx"+randomRange(0,10000);
			}
			else if(_messageId != null && streamMode == MODE_STREAMING)
			{
				streamRequest.url = "http://" + server + "/signalR/?transport=serverSentEvents&connectionId=" + connectionId + "&messageId="+_messageId+"&stream=1&connectionData=[{\"name\":\"Stream\"}]&client=FLEX&prfx"+randomRange(0,10000);
			}
			else
			{
				//streamRequest.url = "http://" + server + "/signalr/connect?transport=serverSentEvents&connectionId=" + connectionId + "&connectionData=[{'name':'Stream'}]&client=FLEX"
			}
						
			trace("Requesting URL:" + streamRequest.url);
			streamLoader.load(streamRequest);
			if(streamMode != MODE_NONSTREAMING)
			{
				//startHeartTimer();
			}			
		}
		
		private function onSendTimer(e:TimerEvent):void
		{
			_sendTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onSendTimer);
			_sendTimer.stop();			
			//createCmdRequest();
			sendFlush();
			
		}			
				
		private function onStreamSecurityError(event:SecurityErrorEvent) : void 
		{
			trace("SecurityErrorEvent: " + event.text);
			dropConnection(event.text);
			return;
		}
		
		private function onStreamOpen(event:Event) : void 
		{
			trace("onStreamOpen");
			
			//if(_connected == true )dispatchEvent(new StreamEvent(StreamEvent.CONNECT));
			if(_connected && sendQueue.length > 0)
			{
				trace("SendFluash called from stream open");
				sendFlush();
			}			
			return;
		}
		
		private function onStreamHttpStatus(event:HTTPStatusEvent) : void 
		{			
			//if (event.status != 0 && event.status != 200 )
			if( event.status == 0 || event.status != 200 )
			{
				trace("onStreamError: " + event.status);
				startDisconnectTimer();
			}
			return;
		}
		
		private function onStreamProgress(event:ProgressEvent) : void 
		{
			//trace("************ on Stream Progress **************");			
			processStreamedData();			
		}
		
		private function onStreamComplete(event:Event) : void 
		{
			trace("************ on Stream Complete **************");	
			processStreamedData();
			if ( (state == STATE_CONNECTED || state == STATE_CONNECTION_TIME_OUT) && processStreamedData())
			{			
				if(streamMode == MODE_STREAMING)
					sendNextRequest();
				else 
					startPollDelayTimer();
			}			
		}
		
		private function onStreamIOError(event:IOErrorEvent) : void 
		{
			trace("onStreamIOError: " + event.text);
			startDisconnectTimer();
			return;
		}
		
		private function dropConnection(param1:String = "") : void 
		{
			disconnect();
			dispatchEvent(new StreamEvent(StreamEvent.DISCONNECT));
			return;
		}
		
		private function startPollDelayTimer():void
		{
			if(_pollDelayTimer == null)
			{				
				_pollDelayTimer = new Timer(250 * _pollDelay,1);
				_pollDelayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onSendNextRequestTimerFire);
				_pollDelayTimer.start();
				
			}
		}
		
		private function startPollDelayTimerFotHttp():void
		{
			if(_pollDelayTimerForHttp == null)
			{				
				_pollDelayTimerForHttp = new Timer(2500,1);
				_pollDelayTimerForHttp.addEventListener(TimerEvent.TIMER_COMPLETE, onSendNextRequestTimerFireForHttp);
				_pollDelayTimerForHttp.start();
				
			}
		}
		
		private function onSendNextRequestTimerFire(e:TimerEvent):void 
		{
			sendNextRequest();
			_pollDelayTimer.reset();
			_pollDelayTimer = null;
			
		}
		
		private function onSendNextRequestTimerFireForHttp(e:TimerEvent):void 
		{
			sendNextRequest();
			_pollDelayTimerForHttp.reset();
			_pollDelayTimerForHttp = null;
			
		}
		
		private function startDisconnectTimer() : void 
		{
			if (_disconnectTimer != null)
			{
				trace("Resetting disconnect timer");
				_disconnectTimer.reset();
				_disconnectTimer.start();
			}
			else
			{
				trace("Setting disconnect timer");
				_disconnectTimer = new Timer(100, 1);
				_disconnectTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onDisconnectTimer);
			}			
		}
		
		private function onDisconnectTimer(event:TimerEvent) : void 
		{			
			dropConnection("");
			_disconnectTimer.reset();
			_disconnectTimer = null;			
		}
		
		private function onConnectionTimedOut(e:TimerEvent) : void 
		{
			if(_messageId == null || _messageId == "" )
				return;
			
			if(_messageId == _lastMessageId)
			{
				_missedCount = _missedCount + 1 ;
				if(_missedCount >= _timeOut && state != STATE_CONNECTION_TIME_OUT )
				{
					state = STATE_CONNECTION_TIME_OUT ; //timedOut
					dispatchEvent(new StreamEvent(StreamEvent.TIME_OUT));
				}
			}
			else
			{
				
				_lastMessageId = _messageId ;
				_missedCount = 0 ;
				if(state == STATE_CONNECTION_TIME_OUT)
				{
					state = STATE_CONNECTED ;
					dispatchEvent(new StreamEvent(StreamEvent.CONTINUED));
				}
				/*_connectionTimeOutTimer.reset();
				_connectionTimeOutTimer = null;*/
			}
		}
				
		private function parseResult(str:String):Object 
		{
			if(str.length < 10 ) new Object();
			var result:String = str.slice(str.indexOf("{"), str.lastIndexOf("}") + 1);
			if(result == "") return new Object();
			var decodedJSON:Object = com.adobe.serialization.json.JSON.decode(result);
			return decodedJSON ;
		}
		
		private function processStreamedData() : Boolean 
		{
			var lastCharIndex:int = 0;
			var response:String = null;
			var count:int = 0;
			var finalFunc:String = null;
			if (streamLoader)
			{
				response = streamLoader.readUTFBytes(streamLoader.bytesAvailable);
				//trace("\n****** recieved Data *****\n" + response );
				//receivedStreamedData = receivedStreamedData + response.replace(/\s+/g, "");
				receivedStreamedData = receivedStreamedData + response.replace(/\n\s+\n|\n/g,"");
				//trace("\n****** receivedStreamedData Data *****\n" + receivedStreamedData );
				
			}
			
			lastCharIndex = receivedStreamedData.lastIndexOf(";");
			if (lastCharIndex > 0)
			{
				count = 0;
				do
				{					
					if (count < receivedStreamedData.length)continue;
					
				}while (receivedStreamedData.charAt(count++) == " ")
				
					
				finalFunc = receivedStreamedData.substring(count == 0 ? (0) : ((count - 1)), lastCharIndex);
				receivedStreamedData = receivedStreamedData.substring((lastCharIndex + 1));
				eval(finalFunc);
			}
			
			return true ;
		}
		
		private function eval(param1:String) : void 
		{
			trace("\n"+param1);
			var _loc_2:Array = null;
			var _loc_3:String = null;
			var _loc_4:int = 0;
			var _loc_5:int = 0;
			var _loc_6:String = null;
			var _loc_7:String = null;
			_loc_2 = param1.split(";");
			for each (_loc_3 in _loc_2)
			{                
				_loc_4 = _loc_3.indexOf("(");
				_loc_5 = _loc_3.indexOf(")");
				
				if (_loc_5 < 0 && _loc_4 >= 0)
				{
					continue;
				}
				_loc_6 = _loc_3.substr(0, _loc_4);
				_loc_7 = _loc_3.substr((_loc_4 + 1), _loc_5 - 2);
				if (_loc_6 == "c")
				{
					c(_loc_7);
				}
				if (_loc_6 == "h")
				{
					h(_loc_7);
				}
				if (_loc_6 == "r")
				{
					r(_loc_7);
				}
				if (_loc_6 == "q")
				{
					q(_loc_7);
				}
				if (_loc_6 == "e")
				{
					e(_loc_7);
				}
				if (_loc_6 == "m")
				{
					var _loc_10:* = this;
					_loc_10[_loc_6](_loc_7);
					continue;
				}				
			}
			return;
		}
		
		private function e(param1:String) : void 
		{
			//trace("e(" + param1 + "); Received Error");
			dropConnection();
			return;
		}
		
		private function h(param1:String) : void 
		{			
			if (streamMode == MODE_UNKNOWN)
			{
				trace("Detected streaming connection");
				streamMode = MODE_STREAMING;
			}
			if (streamMode == MODE_STREAMING)
			{
				missedBeats = 0;
				//startHeartTimer();
			}
			return;
		}
		
		public function m(param1:String) : void 
		{
			var msgEvent:StreamEvent = null;
			//trace("m(" + param1 + ");");
			msgEvent = new StreamEvent(StreamEvent.MESSAGE, new Message());
			msgEvent.message.decode(param1);
			dispatchEvent(msgEvent);
			//streamMode = MODE_NONSTREAMING ;
			//sendNextRequest();
		}
		
		private function q(param1:String) : void 
		{
			var nextQ:int = 0;
			//trace("q(" + param1 + ");");
			nextQ = parseInt(param1);
			nextRecvSeq = nextQ + 1;
			_messageId = param1 ;
		}
		
		private function r(param1:String) : void 
		{
			trace("r(" + param1 + "); Received Refresh Command");
			//_messageId = "0";
			//sendNextRequest();
			dropConnection("Bad Messgae Response");
			return;
		}
		
		private function createCmdRequest() : void 
		{
			if(!_connected)return ;
			cmdService = new HTTPService();
			cmdService.method = "POST";
			cmdService.url = "http://" + server + "/signalR/send?transport=serverSentEvents&connectionId=" + connectionId+"&connectionData=[{\"name\":\"Stream\"}]&client=FLEX" ;
			cmdService.contentType = "text/plain; charset=UTF-8";
			cmdService.addEventListener(FaultEvent.FAULT, onCmdFault, false, 0, true);
			cmdService.addEventListener(ResultEvent.RESULT, onCmdResult, false, 0, true);
			//cmdService.send('{"Hub":"Stream","Method":"Subscribe","Args":["Quotes.ORTE"],"State":{}}');
			return;
		}
		
		
		
		private function c(param1:String):void 
		{						
			connectionId = param1;	
			state = STATE_CONNECTED;
			encoder = "";
			dispatchEvent(new StreamEvent(StreamEvent.CONNECT));
			trace("SendFluash called from C function");
			sendFlush();			
		}
		
		private function sendFlush() : void 
		{
			
			if ((sendQueue.length == 0 && encoder.length == 0) || state != STATE_CONNECTED )
			{
				return;
			}
			
			if (cmdService != null)
			{
				trace("sendFlush is delayed due to existing request");
				return;
			}
			if(_connected)
			{
				createCmdRequest();
				cmdService.send(buildCmdBody());
				trace("Posted: " + encoder);
			}			
			
			return;
		}
		
		private function onCmdResult(event:ResultEvent) : void 
		{			
			trace("Post succeeded: " + event.result);
			cmdService = null;
			encoder = "";			
			sendFlush();
			return;
		}
		
		private function onCmdFault(event:FaultEvent) : void 
		{
			trace("Post failed: " + event.messageId + ": " + event.message + " : " + event.fault);
			dropConnection("Fault on command stream: " + event.fault);			
			return;
		}
		
		public function set connectionTimeOut(val:int):void
		{
			_timeOut = val;		
		}
	}
}