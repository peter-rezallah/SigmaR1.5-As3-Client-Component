package sigma.core
{

    public final class DataItemType extends Object {
        public static const Record:int = 0;
        public static const Dictionary:int = 2;
        public static const Table:int = 1;

        function DataItemType() {
            return;
        }// end function

        public static function getString(param1:int) : String {
            switch(param1){
                case Record:{
                    return "Record";
                }
                case Table:{
                    return "Table";
                }
                case Dictionary:{
                    return "Dictionary";
                }
                default:{
                    return "Unknown ItemType: " + param1;
                    break;
                }
            }
        }// end function

    }
}
