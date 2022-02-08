package sigma.core
{
    import flash.events.*;

    public class DataItemStateEvent extends Event {
        public var dataState:DataState;
        public var dataError:DataError;
        public var message:String;
        public static const STATE:String = "DataItemStateEvent_STATE";

        public function DataItemStateEvent(param1:String, param2:DataState, param3:DataError, param4:String) {
            super(param1);
            this.dataState = param2;
            this.dataError = param3;
            this.message = param4;
            return;
        }// end function

        override public function clone() : Event {
            return new DataItemStateEvent(type, dataState, dataError, message);
        }// end function

    }
}
