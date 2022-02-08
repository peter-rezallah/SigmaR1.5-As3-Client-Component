package sigma.core
{
    import flash.events.*;

    public class TableSetEvent extends Event {
        public var index:int;
        public static const DELETE_COLUMN:String = "TableSetEvent_DELETE_COLUMN";
        public static const DELETE_ROW:String = "TableSetEvent_DELETE_ROW";
        public static const SET_COLUMN_TYPE:String = "TableSetEvent_SET_COLUMN_TYPE";
        public static const SET_COLUMN_NAME:String = "TableSetEvent_SET_COLUMN_NAME";
        public static const SET_ROW_NAME:String = "TableSetEvent_SET_ROW_NAME";

        public function TableSetEvent(param1:String, param2:int) {
            super(param1);
            this.index = param2;
            return;
        }

        override public function clone() : Event {
            return new TableSetEvent(type, index);
        }

    }
}
