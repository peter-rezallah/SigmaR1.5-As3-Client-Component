package sigma.core
{
    import flash.events.*;

    public class TableEvent extends Event 
	{
        public static const ADD_COLUMN:String = "TableEvent_ADD_COLUMN";
        public static const DELETE_ALL_ROWS:String = "TableEvent_DELETE_ALL_ROWS";
        public static const DELETE_ALL_COLUMNS:String = "TableEvent_DELETE_ALL_COLUMNS";
        public static const ADD_ROW:String = "TableEvent_ADD_ROW";

        public function TableEvent(param1:String) 
		{
            super(param1);
            return;
        }

        override public function clone() : Event {
            return new TableEvent(type);
        }

    }
}
