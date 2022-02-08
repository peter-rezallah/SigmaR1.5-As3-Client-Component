package sigma.core
{

    public class TableColumn extends Object 
	{
        public var index:int = -1;
        public var type:DataType;
        public var name:String = "";

        public function TableColumn() 
		{
            type = DataType.None;
            name = "";
            index = -1;
            return;
        }

    }
}
