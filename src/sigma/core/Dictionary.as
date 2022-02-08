package sigma.core
{
    import mx.logging.*;
	import flash.utils.Dictionary ;

    public class Dictionary extends RequestableDataItem 
	{
        private var _items:Array;
        private var _keys:flash.utils.Dictionary;
        private static var _log:ILogger = Log.getLogger("cog.data3.dictionary");

        public function Dictionary() 
		{
            _items = new Array();
            _keys = new flash.utils.Dictionary();
            type = DataItemType.Dictionary;
            format = DataFormat.Dict;
            item = "#dict";
            filter = "*";
            return;
        }// end function

        public function getItemByIndex(param1:int) : DictionaryItem 
		{
            return _items[param1];
        }// end function

        private function setFieldType(param1:int, param2:DataType) : void 
		{
            var _loc_3:DictionaryItem = null;
            _loc_3 = _getItemByKey(param1);
            _loc_3.dataType = param2;
            return;
        }// end function

        public function LookupKey(param1:String) : int 
		{
            var _loc_2:DictionaryItem = null;
			
            for each (_loc_2 in _items)
			{                
                if (_loc_2.name == param1)
				{
                    return _loc_2.key;
                }
            }
            return -1;
        }// end function

        private function setFieldDescription(param1:int, param2:String) : void 
		{
            var _loc_3:DictionaryItem = null;
            _loc_3 = _getItemByKey(param1);
            _loc_3.description = param2;
            return;
        }// end function

        override public function onMessage(param1:Message) : void 
		{
            var _loc_2:Boolean = false;
            switch(param1.type){
                case MessageType.Image:
                case MessageType.Update:
				{
                    if (status != DataState.Live)
					{
                        setStatus(DataState.Live, DataError.None, "");
                    }
                    _loc_2 = param1.type == MessageType.Image;
					
                    if (_loc_2)
					{
                        clear();
                    }
                    dispatchEvent(new DataItemUpdateEvent(DataItemUpdateEvent.BEGIN, _loc_2));
                    decodeMessage(param1);
                    dispatchEvent(new DataItemUpdateEvent(DataItemUpdateEvent.END, _loc_2));
                    break;
                }
                default:{
                    super.onMessage(param1);
                    break;
                }
            }
            return;
        }// end function

        protected function decodeMessage(param1:Message) : Boolean 
		{
            var _loc_2:MessageField = null;
            var _loc_3:int = 0;
            var _loc_4:String = null;
            var _loc_5:String = null;
            var _loc_6:String = null;
			
            for each (_loc_2 in param1.body)
			{
                
                _loc_3 = _loc_2.key;
                _loc_4 = _loc_2.value;
                if (_loc_4.length < 2)
				{
                    _log.error("Invalid dictionary operation: " + _loc_4);
                    return false;
                }
                if (_loc_3 <= 0)
				{
                    _log.error("Invalid dictionary key: " + _loc_3);
                    return false;
                }
                _loc_5 = _loc_4.substr(2, 1);
                _loc_6 = _loc_4.substring(3, (_loc_4.length - 1));
                switch(_loc_5)
				{
                    case "n":
					{
                        setFieldName(_loc_3, _loc_6);
                        break;
                    }
                    case "d":
					{
                        setFieldDescription(_loc_3, _loc_6);
                        break;
                    }
                    case "t":
					{
                        setFieldType(_loc_3, DataType.fromInt(parseInt(_loc_6)));
                        break;
                    }
                    case "a":
					{
                        setFieldAliases(_loc_3, _loc_6);
                        break;
                    }
                    default:{
                        _log.error("Unknown dictionary opcode: " + _loc_5);
                        return false;
                        break;
                    }
                }
            }
            dispatchEvent(new DictionaryEvent(DictionaryEvent.UPDATED, this));
            return true;
        }// end function

        private function setFieldAliases(param1:int, param2:String) : void 
		{
            var _loc_3:DictionaryItem = null;
            _loc_3 = _getItemByKey(param1);
            _loc_3.aliases = param2;
            return;
        }// end function

        public function LookupName(param1:int) : String 
		{
            var _loc_2:DictionaryItem = null;
            _loc_2 = getItemByKey(param1);
            if (_loc_2 == null){
                return null;
            }
            return _loc_2.name;
        }// end function

        private function setFieldName(param1:int, param2:String) : void 
		{
            var _loc_3:DictionaryItem = null;
            _loc_3 = _getItemByKey(param1);
            _loc_3.name = param2;
            return;
        }// end function

        private function _getItemByKey(param1:int) : DictionaryItem {
            var _loc_2:DictionaryItem = null;
            _loc_2 = getItemByKey(param1);
            if (_loc_2 == null)
			{
                _loc_2 = new DictionaryItem();
                _loc_2.key = param1;
                _keys[param1] = _items.length;
                _items.push(_loc_2);
            }
            return _loc_2;
        }// end function

        public function get length() : int 
		{
            return _items.length;
        }// end function

        private function clear() : void 
		{
            _items = new Array();
            _keys = new flash.utils.Dictionary();
            return;
        }// end function

        public function getItemByKey(param1:int) : DictionaryItem 
		{
            var _loc_2:Object = null;
            var _loc_3:int = 0;
            _loc_2 = _keys[param1];
            if (_loc_2 == null)
			{
                return null;
            }
            _loc_3 = int(_loc_2);
            return _items[_loc_3];
        }// end function

    }
}
