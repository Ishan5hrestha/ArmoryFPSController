package internal;

import kha.FastFloat;
import iron.math.Quat;
import iron.math.Vec4;
import iron.object.Object;
import armory.trait.physics.RigidBody;
import armory.trait.physics.PhysicsWorld;
import armory.trait.physics.bullet.PhysicsWorld.Hit;

class OctagonalRayCast {

	static var coords: Array<Array<FastFloat>> = [
		[0.0, 1.0],
		[1.0, 1.0],
		[1.0, 0.0],
		[1.0, -1.0],
		[0.0, -1.0],
		[-1.0, -1.0],
		[-1.0, 0.0],
		[-1.0, 1.0]
	];

	static var from = new Vec4();
	static var to = new Vec4();
	static var hit: Null<Hit>;

	public static function getPyramid(location: Vec4, rotation: Quat, mask: Int, scaleX: FastFloat, scaleY: FastFloat, scaleZ: FastFloat) {
		to.set(0.0, 0.0, scaleZ);
		to.applyQuat(rotation);
		to.add(location);

		hit = PhysicsWorld.active.rayCast(location, to, mask);

		if (hit == null) {
			for (c in coords) {
				to.set(c[0], c[1], 0.0);
				to.normalize();
				to.x *= scaleX;
				to.y *= scaleY;
				to.z = scaleZ;
				to.applyQuat(rotation);
				to.add(location);

				hit = PhysicsWorld.active.rayCast(location, to, mask);

				if (hit != null) {
					break;
				}
			}
		}

		return hit;
	}

	public static function getCylinder(location: Vec4, rotation: Quat, mask: Int, scaleX: FastFloat, scaleY: FastFloat, scaleZ: FastFloat) {
		to.set(0.0, 0.0, scaleZ);
		to.applyQuat(rotation);
		to.add(location);

		hit = PhysicsWorld.active.rayCast(location, to, mask);

		if (hit == null) {
			for (c in coords) {
				from.set(c[0], c[1], 0.0);
				from.normalize();
				from.x *= scaleX;
				from.y *= scaleY;
				from.applyQuat(rotation);
				from.add(location);

				to.set(0.0, 0.0, scaleZ);
				to.applyQuat(rotation);
				to.add(from);

				hit = PhysicsWorld.active.rayCast(from, to, mask);

				if (hit != null) {
					break;
				}
			}
		}

		return hit;
	}
}