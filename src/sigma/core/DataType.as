package sigma.core
{

    final public class DataType extends Object {
        public static const Time:DataType = new DataType;
        public static const Date:DataType = new DataType;
        public static const string:DataType = new DataType;
        public static const None:DataType = new DataType;
        public static const DateTime:DataType = new DataType;
        public static const Float:DataType = new DataType;
        public static const Integer:DataType = new DataType;

        public function DataType() {
            return;
        }// end function

        public static function fromInt(param1:int) : DataType {
            switch(param1){
                case 0:{
                    return None;
                }
                case 1:{
                    return string;
                }
                case 2:{
                    return Integer;
                }
                case 3:{
                    return Float;
                }
                case 4:{
                    return Time;
                }
                case 5:{
                    return Date;
                }
                case 6:{
                    return DateTime;
                }
                default:{
                    return None;
                    break;
                }
            }
        }// end function

        public static function getString(param1:DataType) : String {
            switch(param1){
                case None:{
                    return "None";
                }
                case string:{
                    return "String";
                }
                case Integer:{
                    return "Integer";
                }
                case Float:{
                    return "Float";
                }
                case Time:{
                    return "Time";
                }
                case Date:{
                    return "Date";
                }
                case DateTime:{
                    return "DateTime";
                }
                default:{
                    return "Unknown data type: " + param1;
                    break;
                }
            }
        }// end function

        public static function toInt(param1:DataType) : int {
            switch(param1){
                case None:{
                    return 0;
                }
                case string:{
                    return 1;
                }
                case Integer:{
                    return 2;
                }
                case Float:{
                    return 3;
                }
                case Time:{
                    return 4;
                }
                case Date:{
                    return 5;
                }
                case DateTime:{
                    return 6;
                }
                default:{
                    return 0;
                    break;
                }
            }
        }// end function

    }
}
