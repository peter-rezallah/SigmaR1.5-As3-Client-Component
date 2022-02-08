package sigma.core
{
    import flash.events.*;

    public class StreamEvent extends Event 
	{
        public var message:Message = null;
        public static const MESSAGE:String = "StreamEvent_MESSAGE";
        public static const CONNECT:String = "StreamEvent_CONNECT";
        public static const DISCONNECT:String = "StreamEvent_DISCONNECT";
		public static const RECONNECT:String = "StreamEvent_RECONNECT";
		public static const TIME_OUT:String = "StreamEvent_TIME_OUT";
		public static const CONTINUED:String = "StreamEvent_CONTINUED";

        function StreamEvent(param1:String, param2:Message = null) 
		{
            message = null;
            super(param1);
            this.message = param2;
            return;
        }

        override public function clone() : Event 
		{
            return new StreamEvent(type, message);
        }

    }
}
