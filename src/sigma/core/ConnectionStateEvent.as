package sigma.core
{
    import flash.events.*;

    public class ConnectionStateEvent extends Event 
	{
        private var _state:ConnectionState;
        private var _message:String;
        public static const STATE:String = "ConnectionStateEvent_STATE";

        public function ConnectionStateEvent(param1:String, param2:ConnectionState, param3:String) 
		{
            super(param1);
            _state = param2;
            _message = param3;
            return;
        }// end function

        public function get message() : String {
            return _message;
        }// end function

        public function get state() : ConnectionState {
            return _state;
        }// end function

        override public function clone() : Event {
            return new ConnectionStateEvent(type, state, message);
        }// end function

    }
}
