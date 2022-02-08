package sigma.core
{	

    public class RecordPublisher extends DataItemPublisher 
    {

        public function RecordPublisher() {
            format = DataFormat.Record;
            return;
        }// end function

        public function setFieldByName(param1:String, param2:String, param3:DataType) : void {
            var _loc_4:int = 0;
            var _loc_5:String = null;
            _loc_4 = 0;
            _loc_5 = "#n" + param1;
            message.addBodyField(_loc_4, _loc_5);
            if (param3 != DataType.string){
                _loc_5 = "#t" + DataType.toInt(param3);
                message.addBodyField(_loc_4, _loc_5);
            }
            message.addBodyField(_loc_4, param2);
            return;
        }// end function

        public function removeField(param1:int) : void {
            message.addBodyField(param1, "#d");
            return;
        }// end function

        public function setPartialField(param1:int, param2:int, param3:String) : void {
            var _loc_4:String = null;
            _loc_4 = "#p" + param2 + ":" + param3;
            message.addBodyField(param1, _loc_4);
            return;
        }// end function

        public function setField(param1:int, param2:String) : void {
            
            if (param2.length > 0 && param2.charAt(0) == "#")
			{
                param2 = "#" + param2;
            }
            message.addBodyField(param1, param2);
            return;
        }// end function

    }
}
