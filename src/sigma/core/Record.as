package sigma.core
{
    import flash.utils.Dictionary;
    
    import mx.logging.*;

    public class Record extends RequestableDataItem 
	{
        private var _dictionary:sigma.core.Dictionary = null;
        private var _keys:flash.utils.Dictionary;
        private var _fields:Array;
        private var _useDictionary:Boolean = true;
        private static var _log:ILogger = Log.getLogger("cog.data3.record");

        public function Record() 
		{
            _dictionary = null;
            _useDictionary = true;
            _fields = new Array();
            _keys = new flash.utils.Dictionary();
            type = DataItemType.Record;
            format = DataFormat.Record;
            return;
        }// end function

        public function hasField(param1:int) : Boolean 
		{
            var _loc_2:RecordField = null;
            _loc_2 = _keys[param1];
            return _loc_2 != null;
        }// end function

        public function get useDictionary() : Boolean 
		{
            return _useDictionary;
        }// end function

        public function set useDictionary(param1:Boolean) : void 
		{
            if (_readOnly)
			{
                throw "item is readonly";
            }
            _useDictionary = param1;
            return;
        }// end function

        public function get dictionary() : sigma.core.Dictionary 
		{
            return _dictionary;
        }// end function

        public function getFieldByKey(param1:int) : RecordField 
		{
            var _loc_2:RecordField = null;
            _loc_2 = _keys[param1];
            return _loc_2;
        }// end function

        override public function onMessage(param1:Message) : void 
		{
            var isImage:Boolean = false;
            switch(param1.type)
			{
                case MessageType.Image:
                case MessageType.Update:
				{
                    if (status != DataState.Live)
					{
                        setStatus(DataState.Live, DataError.None, "");
                    }
					isImage = param1.type == MessageType.Image;
                    dispatchEvent(new DataItemUpdateEvent(DataItemUpdateEvent.BEGIN, isImage));
                    if (isImage)
					{
                        clear();
                    }
                    decodeMessage(param1);
                    dispatchEvent(new DataItemUpdateEvent(DataItemUpdateEvent.END, isImage));
                    break;
                }
                default:{
                    super.onMessage(param1);
                    break;
                }
            }
            return;
        }// end function

        private function setField(param1:int, param2:String) : void {
            var _loc_3:RecordField = null;
            var _loc_4:int = 0;
            if (param2.length >= 2){
            }
            if (param2.charAt(0) == "\"")
			{
                param2 = param2.slice(1, (param2.length - 1));
            }
            _loc_3 = getFieldByKey(param1);
           
			if (!_loc_3)
			{
                _loc_4 = _fields.length;
                _loc_3 = new RecordField();
                _loc_3.init(_dictionary, _loc_4, param1);
                _loc_3._value = param2;
                _keys[param1] = _loc_3;
                _fields[_loc_4] = _loc_3;
                dispatchEvent(new RecordEvent(RecordEvent.APPEND, _loc_4, param1));
            }
            else
			{
                _loc_3._value = param2;
                dispatchEvent(new RecordEvent(RecordEvent.UPDATE, _loc_3.index, _loc_3.key));
            }
            return;
        }// end function

        protected function decodeMessage(param1:Message) : Boolean 
		{
            var msgField:MessageField = null;
            var recordKeyIndex:int = 0;
            var recordKeyValue:String = null;
            var _loc_5:int = 0;
            var _loc_6:int = 0;
            var _loc_7:String = null;
			
            for each (msgField in param1.body)
			{
                
				recordKeyIndex = msgField.key;
				recordKeyValue = msgField.value;
				
				
                if ( recordKeyIndex < 0)
				{
                    _log.warn("Invalid record key: " + recordKeyIndex );
                    return false;
                }
				
                if (recordKeyValue != "" && recordKeyValue.charAt(0) != "#" )
				{
					setField(recordKeyIndex, recordKeyValue);
					continue;
                }
                
                if (recordKeyValue.length == 1)
				{
                    _log.warn("Missing opcode in record update");
                    return false;
                }
                switch(recordKeyValue.charAt(1))
				{
                    case "d":
					{
                        delField(recordKeyIndex);
                        break;
                    }
                    case "p":
					{
						recordKeyValue = recordKeyValue.substring(2, (recordKeyValue.length - 1));
                        _loc_5 = recordKeyValue.indexOf(":");
                        if (_loc_5 < 0)
						{
                            _log.warn("Missing separator in partial update");
                            return false;
                        }
                        _loc_6 = parseInt(recordKeyValue.substring(0, _loc_5));
                        _loc_7 = recordKeyValue.substring(_loc_5);
                        setPartial(recordKeyIndex, _loc_6, _loc_7);
                        break;
                    }
                    case "#":
					{
                        setField(recordKeyIndex, recordKeyValue.substring(2, (recordKeyValue.length - 1)));
                        break;
                    }
                    default:
					{
                        _log.warn("Unknown record update type: " + recordKeyValue.charAt(1));
                        return false;
                        break;
                    }
                }
            }
            return true;
        }// end function

        private function setPartial(param1:int, param2:int, param3:String) : void {
            var _loc_4:Boolean = false;
            var _loc_5:RecordField = null;
            var _loc_6:String = null;
            var _loc_7:String = null;
            var _loc_8:String = null;
            _loc_4 = hasField(param1);
            if (!_loc_4){
                setField(param1, param3);
                return;
            }
            _loc_5 = getFieldByKey(param1);
            _loc_6 = _loc_5.displayValue;
            _loc_7 = _loc_6.substring(0, param2);
            _loc_8 = _loc_6.substring(param2 + param3.length);
            _loc_6 = _loc_7 + param3 + _loc_8;
            _loc_5._value = _loc_6;
            dispatchEvent(new RecordEvent(RecordEvent.UPDATE, _loc_5.index, _loc_5.key));
            return;
        }// end function

        public function get fieldCount() : int {
            return _fields.length;
        }// end function

        public function getIndexByKey(param1:int) : int {
            var _loc_2:RecordField = null;
            _loc_2 = _keys[param1];
            if (_loc_2 == null){
                return -1;
            }
            return _loc_2.index;
        }// end function

        public function getKeyByIndex(param1:int) : int {
            var _loc_2:RecordField = null;
            _loc_2 = _fields[param1];
            if (_loc_2 == null){
                return -1;
            }
            return _loc_2.key;
        }// end function

        public function getFieldByIndex(param1:int) : RecordField 
		{
            return _fields[param1];
        }// end function

        override public function subscribe() : void 
		{
            if (!useDictionary)
			{
                if (_dictionary != null)
				{
                    _dictionary = null;
                }
            }
            else{
                _dictionary = connection.getDictionary(source);
            }
            super.subscribe();
            return;
        }// end function

        private function clear() : void {
            _fields = new Array();
            _keys = new flash.utils.Dictionary();
            return;
        }// end function

        public function getFieldByName(param1:String) : RecordField {
            var _loc_2:int = 0;
            if (_dictionary == null)
			{
                return null;
            }
            _loc_2 = _dictionary.LookupKey(param1);
            if (_loc_2 < 0){
                return null;
            }
            return getFieldByKey(_loc_2);
        }// end function

        private function delField(param1:int) : void {
            var _loc_2:RecordField = null;
            var _loc_3:int = 0;
            var _loc_4:int = 0;
            _loc_2 = getFieldByKey(param1);
            if (_loc_2 == null){
                return;
            }
            _loc_3 = _loc_2.index;
            if (_loc_3 < 0){
                return;
            }
            dispatchEvent(new RecordEvent(RecordEvent.DELETE, _loc_3, param1));
            _fields.removeItemAt(_loc_3);
            _keys[param1] = null;
            _loc_4 = _loc_3;
            while (_loc_4 < _fields.length){
                
                var _loc_5:* = _fields[_loc_4];
                var _loc_6:* = _fields[_loc_4]._index - 1;
                _loc_5._index = _loc_6;
                _loc_4 = _loc_4 + 1;
            }
            return;
        }// end function

    }
}
