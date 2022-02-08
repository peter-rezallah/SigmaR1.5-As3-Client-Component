package sigma.core
{
    import flash.events.*;

    public class DictionaryEvent extends Event {
        public var dictionary:Dictionary;
        public static const UPDATED:String = "DictionaryEvent_UPDATED";

        public function DictionaryEvent(param1:String, param2:Dictionary) {
            super(param1);
            this.dictionary = param2;
            return;
        }// end function

        override public function clone() : Event {
            return new DictionaryEvent(type, dictionary);
        }// end function

    }
}
