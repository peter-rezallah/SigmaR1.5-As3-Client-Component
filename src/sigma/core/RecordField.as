package sigma.core
{

    public class RecordField extends Object 
	{
        private var _key:int;
        private var _dictItem:DictionaryItem = null;
        
		public var _value:String = "";
		public var _index:int;

        public function RecordField() 
		{
            _value = "";
            _dictItem = null;
            return;
        }// end function

        public function get name() : String 
		{
            if (!_dictItem)
			{
                throw new Error("no dictionary available");
            }
            return _dictItem.name;
        }// end function

        public function get value() : Object 
		{
            var _loc_1:Date = null;
            if (!_dictItem)
			{
                return _value;
            }
			
            switch(_dictItem.dataType)
			{
                default:
				{
                    return _value;
                }
                case DataType.Float:
				{
                    //return parseInt(_value);
					return parseFloat(_value);
                }
                case DataType.Time:
				{
                    return parseFloat(_value);
                }
                case DataType.Date:{
                    _loc_1 = new Date();
                    _loc_1.setTime(Date.parse(_value + " 01/01/1970"));
                    return _loc_1;
                }
                case DataType.DateTime:{
                    return Date.parse(_value);
                }
                /*case *:{
                    return Date.parse(_value);
                    break;
                }*/
            }
        }// end function

        public function init(param1:Dictionary, param2:int, param3:int) : void {
            if (param1 != null)
			{
                _dictItem = param1.getItemByKey(param3);
            }
            _index = param2;
            _key = param3;
            return;
        }// end function

        public function get index() : int {
            return _index;
        }// end function

        public function get type() : DataType 
		{
            if (!_dictItem)
			{
                throw new Error("no dictionary available");
            }
            return _dictItem.dataType;
        }// end function

        public function get description() : String 
		{
            if (!_dictItem){
                throw new Error("no dictionary available");
            }
            return _dictItem.description;
        }// end function

        public function get displayValue() : String {
            return _value;
        }// end function

        public function get key() : int {
            return _key;
        }// end function

    }
}
