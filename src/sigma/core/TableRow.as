package sigma.core
{

    public class TableRow extends Object 
	{
        public var index:int = -1;
        public var cells:Array;
        public var name:String = "";

        public function TableRow() 
		{
            name = "";
            index = -1;
            cells = new Array();
            return;
        }

    }
}
