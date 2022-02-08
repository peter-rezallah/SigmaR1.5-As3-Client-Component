package sigma.core
{

    public class DictionaryItem extends Object 
	{
        public var dataType:DataType;
        public var name:String = "";
        public var description:String = "";
        public var aliases:String = "";
        public var key:int;

        public function DictionaryItem() {
            name = "";
            aliases = "";
            description = "";
            dataType = DataType.None;
            return;
        }// end function

    }
}
