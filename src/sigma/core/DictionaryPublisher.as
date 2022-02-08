package sigma.core
{
	

    public class DictionaryPublisher extends DataItemPublisher {

        public function DictionaryPublisher() 
		{
            format = DataFormat.Dict;
			/* my code */
			item = "#dict";
			/*------*/
            return;
        }// end function

        public function setFieldType(param1:int, param2:DataType) : void 
		{
            var _loc_3:String = null;
            _loc_3 = "#t" + DataType.toInt(param2);
            message.addBodyField(param1, _loc_3);
            return;
        }// end function

        public function setFieldName(param1:int, param2:String) : void 
		{
            var _loc_3:String = null;
            _loc_3 = "#n" + param2;
            message.addBodyField(param1, _loc_3);
            return;
        }// end function

        public function setFieldDescription(param1:int, param2:String) : void 
		{
            var _loc_3:String = null;
            _loc_3 = "#d" + param2;
            message.addBodyField(param1, _loc_3);
            return;
        }// end function

        public function setFieldAliases(param1:int, param2:String) : void 
		{
            var _loc_3:String = null;
            _loc_3 = "#a" + param2;
            message.addBodyField(param1, _loc_3);
            return;
        }// end function

    }
}
