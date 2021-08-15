package arm;

import iron.Scene;
import iron.math.Vec4;
import iron.system.Time;
import iron.math.Quat;
import iron.system.Input;
import armory.trait.physics.RigidBody;
import armory.trait.physics.bullet.PhysicsWorld;
import armory.system.InputMap;

class CharacterController extends iron.Trait {

	var run_speed = 5.0; //additional speed
	var speed = 5.0;

	var moveX = new InputMap();
	var moveY = new InputMap();
	var jump  = new InputMap();

	var sprint = new InputMap();

	var rb: RigidBody;
	var velocity = new Vec4();

	var helpQuat = new Quat();

	var physWorld: PhysicsWorld; // Physics world
	var scanDepth = 1.1; // Depth to which ray must be cast

	var gravity = new Vec4(0.0,0.0,-9.8);

	var jumpImpulse = 7; // Jumping impulse


	public function new() {
		super();

		Scene.active.notifyOnInit(init);
	}

	function init() {
		physWorld = PhysicsWorld.active;
		rb = object.getTrait(RigidBody);
		rb.setAngularFactor(0.0, 0.0, 0.0); // Prevent physics engine from rotating the character
		rb.setGravity(new Vec4(0.0,0.0,-9.8));
		rb.disableGravity(); // We need to have full control over the gravity to make it easier to fly or simple control the fall speed
		rb.setFriction(0); // Disable friction, so the rb will slide over surfaces
		rb.setActivationState(DISABLE_DEACTIVATION); // If the rb is stopped for a while, its physics will be turned off without this line

		// Add input map keys
		moveX.addKeyboard("d");
		moveX.addKeyboard("a", -1.0);
		moveY.addKeyboard("w");
		moveY.addKeyboard("s", -1.0);
		jump.addKeyboard("space");
		sprint.addKeyboard("shift");

		Input.getMouse().lock();

		physWorld.notifyOnPreUpdate(update);
	}

	function update() {
		//Checking if on ground
		var objectLoc = object.transform.world.getLoc();
		var rayLoc = objectLoc.clone();
		rayLoc.z -= scanDepth;
		var hit = physWorld.rayCast(objectLoc, rayLoc, 1, 2);
		
		//When on ground
		var btvec = rb.getLinearVelocity();
		
		if (hit==null) {
			//rb.setLinearVelocity(velocity.x, velocity.y, btvec.z-1.0);
			rb.enableGravity();
		}
		else{

			//Move
			rb.disableGravity();
			velocity.set(moveX.value(), moveY.value(), 0.0);
			velocity.normalize(); // Normalize the vector to don't go too fast diagonally. You can remove this line to see what happens
			velocity.mult(speed+run_speed*sprint.value());											// for run
			helpQuat.fromTo(object.transform.right(), Scene.active.camera.transform.right());
			velocity.applyQuat(helpQuat);
			helpQuat.fromTo(Vec4.zAxis(), hit.normal);
			velocity.applyQuat(helpQuat);
			rb.setLinearVelocity(velocity.x, velocity.y, velocity.z + jumpImpulse * jump.value());	//for Jumping

		}
			
	}
}

@:enum abstract ActivationStates(Int) from Int to Int {
	var ACTIVE;
	var ISLAND_SLEEPING;
	var WANTS_DEACTIVATION;
	var DISABLE_DEACTIVATION;
	var DISABLE_SIMULATION;
}