package sigma.core
{

    final public class DataError extends Object {
        public static const AlreadyMounted:DataError = new DataError;
        public static const InvalidRequest:DataError = new DataError;
        public static const InvalidUser:DataError = new DataError;
        public static const InvalidItem:DataError = new DataError;
        public static const PermissionDenied:DataError = new DataError;
        public static const InvalidSource:DataError = new DataError;
        public static const NotRequested:DataError = new DataError;
        public static const None:DataError = new DataError;
        public static const NotLoggedIn:DataError = new DataError;
        public static const InvalidProtocol:DataError = new DataError;
        public static const InvalidArg:DataError = new DataError;

        public function DataError() {
            return;
        }// end function

        public static function fromInt(param1:int) : DataError 
		{
            switch(param1){
                case 0:
				{
                    return None;
                }
                case 1:
				{
                    return InvalidRequest;
                }
                case 2:{
                    return InvalidArg;
                }
                case 3:{
                    return InvalidSource;
                }
                case 4:{
                    return InvalidItem;
                }
                case 5:{
                    return AlreadyMounted;
                }
                case 6:{
                    return PermissionDenied;
                }
                case 7:{
                    return NotRequested;
                }
                case 8:{
                    return NotLoggedIn;
                }
                case 9:{
                    return InvalidUser;
                }
                case 10:{
                    return InvalidProtocol;
                }
                default:{
                    return InvalidArg;
                    break;
                }
            }
        }// end function

        public static function getString(param1:DataError) : String {
            switch(param1){
                case None:{
                    return "None";
                }
                case InvalidRequest:{
                    return "InvalidRequest";
                }
                case InvalidArg:{
                    return "InvalidArg";
                }
                case InvalidSource:{
                    return "InvalidSource";
                }
                case InvalidItem:{
                    return "InvalidItem";
                }
                case InvalidItem:{
                    return "InvalidItem";
                }
                case AlreadyMounted:{
                    return "AlreadyMounted";
                }
                case PermissionDenied:{
                    return "PermissionDenied";
                }
                case NotRequested:{
                    return "NotRequested";
                }
                case NotLoggedIn:{
                    return "NotLoggedIn";
                }
                case InvalidUser:{
                    return "InvalidUser";
                }
                case InvalidProtocol:{
                    return "InvalidProtocol";
                }
                default:{
                    return "Unknown data error: " + param1;
                    break;
                }
            }
        }// end function

    }
}
