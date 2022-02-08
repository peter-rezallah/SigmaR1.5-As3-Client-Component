package sigma.core
{
    import flash.utils.*;

    public class Message extends Object 
	{
        public var body:Array;
        public var type:int;
        private var header:flash.utils.Dictionary;

        function Message() 
		{
            type = MessageType.Error;
            header = new flash.utils.Dictionary();
            body = new Array();
            return;
        }

        public function hasKey(param1:int) : Boolean 
		{
            return header[param1] == null;
        }

        public function getStringByKey(param1:int, param2:String) : String 
		{
            var _loc_3:Object = null;
            _loc_3 = header[param1];
            if (_loc_3 != null)
			{
                return _loc_3.value ;
            }
            return param2;
        }

		public function decode(param1:String) : Boolean 
		{
            var pattern:RegExp = null;
            var arrayOfMsgStrings:Array = null;
            var msgField:MessageField = null;
            var _loc_5:int = 0;
            var counter:int = 0;
			//        /\d+\,(?:[\d.]+|""([^""\\\]|\\\.)*"")""\d+\,(?:[\d.]+|"([^"\\]|\\.)*")/g
			pattern = /\d+\,(?:[\d.]+|"([^"\\]|\\.)*")/g;
			//pattern = /\d+\,(?:[\d.]+|([^"\\]|\\.)*")\d+\,(?:[\d.]+|"([^"\\]|\\.)*")/g;
			
			arrayOfMsgStrings = param1.match(pattern);
            if (arrayOfMsgStrings.length < 1)
			{
                return false;
            }
            header = new flash.utils.Dictionary();
            body = new Array();
			msgField = decodeField(arrayOfMsgStrings[0]);
            type = msgField.key;
            _loc_5 = parseInt(msgField.value) + 1;
			counter = 1;
			
            while (counter < arrayOfMsgStrings.length)
			{
                
				msgField = decodeField(arrayOfMsgStrings[counter]);
                if (counter < _loc_5)
				{
                    header[msgField.key] = msgField;
                }
                else
				{
                    body.push(msgField);
                }
				counter = counter + 1;
            }
            return true;
        }

        public function addString(param1:int, param2:String) : void 
		{
            var msgField:MessageField = null;
			msgField = new MessageField();
			msgField.key = param1;
			msgField.value = param2;
            addField(param1, msgField);
            
        }

        private function headerLength() : int 
		{
            var length:int = 0;
            var obj:Object = null;
			
			length = 0;
            for (obj in header)
			{                
				length = length + 1;
            }
			
            return length ;
        }

        public function addInt(param1:int, param2:int) : void 
		{
            addString(param1, param2.toString());
            return;
        }

		public function encode() : String 
		{
			// m(Msg Type , header leangth , header msgField key , header msgField value , body msgField key , body msgField value ) ;
			// m(6,2,4,1,1,2,12,"18/09/2013 16:43:43");
			// m(7,1,1,2,12,"18/09/2013 17:13:15");
			
			
            var str:String = null;
            var msgField:MessageField = null;
			str = "";
			str = str + type;
			str = str + ",";
			str = str + headerLength();
			
            for each (msgField in header)
			{
                
				str = str + ("," + msgField.key + "," + encodeValue(msgField.value));
            }
			
            for each (msgField in body)
			{
                
				str = str + ("," + msgField.key + "," + encodeValue(msgField.value));
            }
            return str ;
        }

        public function addBodyField(param1:int, param2:String) : void 
		{
			
            var msgField:MessageField = null;
			msgField = new MessageField();
			msgField.key = param1;
			msgField.value = param2;
            body.push(msgField);
            return;
        }

		public function addField(param1:int, param2:MessageField) : void 
		{
            header[param1] = param2;
            return;
        }

        public function getIntByKey(param1:int, param2:int) : int 
		{
			var a:String = getStringByKey(param1, String(param2));
            return int(a.slice(a.indexOf('"')+1, a.lastIndexOf('"') ));
        }

        private static function encodeValue(param1:String) : String 
		{
            /*if (isNaN(parseFloat(param1)))
			{
				trace("param1 = " + param1 ) ;
                return  '"'+param1+'"' ;
            }else if(isNaN(parseInt(param1)))
				{
					trace("param11 = " + param1 ) ;
					return  '"'+param1+'"' ;
				}else trace("param111 = " + param1 ) ;*/
			
            return '"'+param1+'"';
        }

        private static function decodeField(param1:String) : MessageField 
		{
            var index:int = 0;
            var msgField:MessageField = null;
			index = param1.indexOf(",");
			msgField = new MessageField();
			msgField.key = parseInt(param1.slice(0, index));
			msgField.value = param1.slice((index + 1));
            return msgField;
        }

        private static function decodeValue(param1:String) : String 
		{
            
            if (param1.length > 1 && param1[0] == '"')
			{
                return param1.substring(1, (param1.length - 1));
            }
            return param1;
        }
		
		public function get tagIndex():int
		{
			return header[1].value;
		}

    }
}
