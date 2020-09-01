// Only used as a return type for Sayer.say

import com.stencyl.models.Actor;

class SayerReturnObject {
	public var actor : Actor;
	public var textBoxIndex : Int;
	public function new(a, i) {
		actor = a;
		textBoxIndex = i;
	}
}