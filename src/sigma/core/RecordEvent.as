package sigma.core
{
    import flash.events.*;

    public class RecordEvent extends Event {
        public var index:int;
        public var key:int;
        public static const UPDATE:String = "RecordEvent_UPDATE";
        public static const APPEND:String = "RecordEvent_APPEND";
        public static const DELETE:String = "RecordEvent_DELETE";

        public function RecordEvent(param1:String, param2:int, param3:int) {
            super(param1);
            this.index = param2;
            this.key = param3;
            return;
        }// end function

        override public function clone() : Event {
            return new RecordEvent(type, index, key);
        }// end function

    }
}
