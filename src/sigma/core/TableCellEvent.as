package sigma.core
{
    import flash.events.*;

    public class TableCellEvent extends Event 
	{
        public var row:int;
        public var column:int;
        public static const SET_USERDATA:String = "TableCellEvent_SET_USERDATA";
        public static const SET_CELL:String = "TableCellEvent_SET_CELL";

        public function TableCellEvent(param1:String, param2:int, param3:int) 
		{
            super(param1);
            this.row = param2;
            this.column = param3;            
        }

        override public function clone() : Event 
		{
            return new TableCellEvent(type, row, column);
        }

    }
}
