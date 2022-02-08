package sigma.core
{

    public final class MessageType extends Object 
	{
        public static const Error:int = 9;
        public static const Login:int = 1;
        public static const Subscribe:int = 2;
        public static const Dismount:int = 5;
        public static const Update:int = 7;
        public static const Unsubscribe:int = 3;
        public static const Status:int = 8;
        public static const Mount:int = 4;
        public static const Image:int = 6;

        function MessageType() 
		{
            return;
        }// end function

        public static function getString(param1:int) : String {
            switch(param1){
                case Login:{
                    return "Login";
                }
                case Subscribe:{
                    return "Subscribe";
                }
                case Unsubscribe:{
                    return "Unsubscribe";
                }
                case Mount:{
                    return "Mount";
                }
                case Dismount:{
                    return "Dismount";
                }
                case Image:{
                    return "Image";
                }
                case Update:{
                    return "Update";
                }
                case Status:{
                    return "Status";
                }
                case Error:{
                    return "Error";
                }
                default:{
                    return "Unknown message type: " + param1;
                    break;
                }
            }
        }// end function

    }
}
