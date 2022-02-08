package sigma.core
{

    final public class ConnectionState extends Object 
	{
        public static const Connecting:ConnectionState = new ConnectionState;
        public static const Connected:ConnectionState = new ConnectionState;
        public static const Disconnected:ConnectionState = new ConnectionState;
		public static const TimeOut:ConnectionState = new ConnectionState;
		public static const Continued:ConnectionState = new ConnectionState;

        public function ConnectionState() 
		{
            return;
        }

        public static function fromInt(param1:int) : ConnectionState {
            switch(param1)
			{
                case 0:{
                    return Disconnected;
                }
                case 1:{
                    return Connecting;
                }
                case 2:{
                    return Connected;
                }
				case 3:{
					return TimeOut;
				}
				case 4:{
					return Continued;
				}
                default:{
                    return Disconnected;
                    break;
                }
            }
        }// end function

        public static function getString(param1:ConnectionState) : String {
            switch(param1){
                case Connected:{
                    return "Connected";
                }
                case Connecting:{
                    return "Connecting";
                }
                case Disconnected:{
                    return "Disconnected";
                }
				case TimeOut:{
					return "TimeOut";
				}
				case Continued:{
					return "Continued";
				}
                default:{
                    return "Unknown Connection type: " + param1;
                    break;
                }
            }
        }// end function

    }
}
