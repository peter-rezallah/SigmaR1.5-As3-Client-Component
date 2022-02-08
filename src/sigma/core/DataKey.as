package sigma.core
{

    public final class DataKey extends Object 
	{
        public static const Password:int = 34;
        public static const Text:int = 7;
        public static const Conflation:int = 10;
        public static const Format:int = 4;
        public static const Filter:int = 9;
        public static const Error:int = 6;
        public static const Params:int = 8;
        public static const State:int = 5;
        public static const Item:int = 3;
        public static const Username:int = 33;
        public static const Protocol:int = 32;
        public static const Tag:int = 1;
        public static const Source:int = 2;
        public static const Application:int = 35;

        public function DataKey() 
		{
            return;
        }

        public static function getString(param1:int) : String 
		{
            switch(param1)
			{
                case Tag:{
                    return "Tag";
                }
                case Source:{
                    return "Source";
                }
                case Item:{
                    return "Item";
                }
                case Format:{
                    return "Format";
                }
                case State:{
                    return "State";
                }
                case Error:{
                    return "Error";
                }
                case Text:{
                    return "Text";
                }
                case Params:{
                    return "Params";
                }
                case Filter:{
                    return "Filter";
                }
                case Conflation:{
                    return "Conflation";
                }
                case Protocol:{
                    return "Protocol";
                }
                case Username:{
                    return "Username";
                }
                case Password:{
                    return "Password";
                }
                case Application:{
                    return "Application";
                }
                default:
				{
                    return "Unknown data type: " + param1;
                    break;
                }
            }
        }

    }
}
