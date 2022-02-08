package sigma.core
{
    import flash.events.*;

    public class TableMoveEvent extends Event 
	{
        public var dstIndex:int;
        public var srcIndex:int;
        public static const MOVED_COLUMN:String = "MessageEvent_MOVED_COLUMN";
        public static const MOVED_ROW:String = "MessageEvent_MOVED_ROW";
        public static const MOVING_COLUMN:String = "MessageEvent_MOVING_COLUMN";
        public static const MOVING_ROW:String = "MessageEvent_MOVING_ROW";

        public function TableMoveEvent(param1:String, param2:int, param3:int) 
		{
            super(param1);
            this.srcIndex = param2;
            this.dstIndex = param3;            
        }

        override public function clone() : Event 
		{
            return new TableMoveEvent(type, srcIndex, dstIndex);
        }

    }
}
