package arm;

import kha.FastFloat;
import iron.Scene;
import iron.math.Vec4;
import iron.system.Time;
import iron.system.Input;
import iron.object.Object;
import armory.math.Helper;
import armory.trait.physics.PhysicsWorld;
import armory.system.InputMap;

class CameraController extends iron.Trait {

	var maxPitch = Math.PI * 0.5; // 90 degrees in radians

	var verticalRot = new InputMap();
	var horizontalRot = new InputMap();
	var escape	= new InputMap();

	var x = 0.0;
	var z = 0.0;

	public function new() {
		super();

		Scene.active.notifyOnInit(init);
		
	}

	function init() {
		verticalRot.addMouse("movement y", -0.2);
		horizontalRot.addMouse("movement x", -0.2);

		verticalRot.addKeyboard("up", -1.5);
		verticalRot.addKeyboard("down", 1.5);

		horizontalRot.addKeyboard("left", -1.5);
		horizontalRot.addKeyboard("right", 1.5);

		escape.addKeyboard("escape",1);

		PhysicsWorld.active.notifyOnPreUpdate(update);
	}

	function update() {

		var mouse = Input.getMouse();
		if (escape.value()==1){
			if (mouse.locked) mouse.unlock();
			//else mouse.lock();
		}
		if (mouse.locked){
			var delta = Time.delta;

			x += verticalRot.value() * delta;
			x = Helper.clamp(x, -maxPitch, maxPitch); // Clamp to avoid 360 in vertical axis

			z += horizontalRot.value() * delta;

			object.transform.rot.fromEuler(x, 0.0, z);
			object.transform.buildMatrix();
		}
	}
}
