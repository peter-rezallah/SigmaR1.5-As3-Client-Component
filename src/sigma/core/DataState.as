package sigma.core
{

    final public class DataState extends Object {
        public static const Closed:DataState = new DataState;
        public static const Pending:DataState = new DataState;
        public static const Stale:DataState = new DataState;
        public static const Live:DataState = new DataState;

        public function DataState() {
            return;
        }// end function

		public static function fromInt(param1:int) : DataState {
            switch(param1){
                case 0:{
                    return Live;
                }
                case 1:{
                    return Pending;
                }
                case 2:{
                    return Stale;
                }
                case 3:{
                    return Closed;
                }
                default:{
                    return Closed;
                    break;
                }
            }
        }// end function

        public static function getString(param1:DataState) : String {
            switch(param1){
                case Live:{
                    return "Live";
                }
                case Pending:{
                    return "Pending";
                }
                case Stale:{
                    return "Stale";
                }
                case Closed:{
                    return "Closed";
                }
                default:{
                    return "Unknown DataState: " + param1;
                    break;
                }
            }
        }// end function

    }
}
