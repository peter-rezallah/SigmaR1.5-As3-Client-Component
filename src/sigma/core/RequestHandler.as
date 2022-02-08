package sigma.core
{

    public final class RequestHandler extends Object 
	{
        private var _msg:Message;
        private var _state:int;
        private var _events:IRequestEvents;
        private var _id:int;
        private var _connection:Connection;
		
        public static const Error:int = 3;
        public static const Open:int = 2;
        public static const Closed:int = 0;
        public static const Opening:int = 1;

        function RequestHandler(id:int, msg:Message, evt:IRequestEvents, conn:Connection) : void 
		{
            var _conflation:int = 0;
            _id = id ;
            _msg = msg ;
            _connection = conn ;
            _events = evt ;
            _state = RequestHandler.Closed;
            _msg.addInt(DataKey.Tag, _id);
			_conflation = conn.conflation;
			
            if (!_msg.getIntByKey(DataKey.Conflation, -1) < 0)
			{
                _msg.addInt(DataKey.Conflation, _conflation );
            }
            
        }

        public function onMessage(param1:Message) : void 
		{
            if (_state == RequestHandler.Opening)
			{
                _state = RequestHandler.Open;
            }
            if (_state == RequestHandler.Open)
			{
                _events.onMessage(param1);
            }
            
        }

        public function open() : void 
		{
            if (_state == RequestHandler.Error || _state == RequestHandler.Opening )
			{
                return;
            }            
            _connection.send(_msg);
            _state = RequestHandler.Opening;
            
        }

        public function onDisconnected() : void 
		{			
            var msg:Message = null;
			msg = new Message();
			msg.type = MessageType.Status;
			msg.addInt(DataKey.State, int(DataState.Stale));
			msg.addInt(DataKey.Error, int(DataError.NotLoggedIn));
            onMessage(msg);
            _state = RequestHandler.Closed;            
        }

        public function close() : void 
		{
            var msg:Message = null;            
            if (_state != RequestHandler.Opening && _state == RequestHandler.Open)
			{
                _state = RequestHandler.Closed;
				msg = new Message();
				msg.type = MessageType.Unsubscribe;
				msg.addInt(DataKey.Tag, _id);
                _connection.send(msg);
            }
            
        }

    }
}
