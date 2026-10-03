module main;
import raylib;
import std.string : fromStringz;
import std.algorithm.comparison : cmp;


// WASD + Ctrl + Space movement
void updateCamera(
  ref Camera3D camera,
  float moveSpeed,
  float mouseSensitivity
) {
  Vector3 movement = Vector3.zero;
  Vector3 rotation = Vector3(0, 0, 0);
  float step = moveSpeed * GetFrameTime();
  if (IsKeyDown(KeyboardKey.KEY_W)) movement.x += step;
  if (IsKeyDown(KeyboardKey.KEY_S)) movement.x -= step;
  if (IsKeyDown(KeyboardKey.KEY_D)) movement.y += step;
  if (IsKeyDown(KeyboardKey.KEY_A)) movement.y -= step;
  if (IsKeyDown(KeyboardKey.KEY_SPACE)) movement.z += step;
  if (IsKeyDown(KeyboardKey.KEY_LEFT_CONTROL)) movement.z -= step;
  rotation.x = GetMouseDelta().x * mouseSensitivity;
  rotation.y = GetMouseDelta().y * mouseSensitivity;
  UpdateCameraPro(&camera, movement, rotation, 0.0f);
}


int main() {
	// Pre-window init variables
	const float moveSpeed = 25;
	const float mouseSensitivity = 0.05f;
  Color DARKGRAY = Color(80, 80, 80);
  Camera3D camera = Camera3D(
    position:   Vector3(10, 5, 0),
    target:     Vector3(0, 5, 5),
    up:         Vector3(0.0f, 1.0f, 0.0f),
    fovy:       90.0f,
    projection: CameraProjection.CAMERA_PERSPECTIVE
  );

	// Window init
  InitWindow(896, 560, "D project");
  SetTargetFPS(24);
  DisableCursor();

  // Load default shader
  Shader shader = LoadShader("NULL", "NULL");

  // Load animated model
  Model modelArm = LoadModel("assets/wave.glb");
  int armAnimationCount = 0;
  ModelAnimation* armAnimations = LoadModelAnimations("assets/wave.glb", &armAnimationCount);
  // Find the index of the desired animation
  int animationIndex;
  for (int i = 0; i <= armAnimationCount; i++) {
    assert(i != armAnimationCount, "Animation not found");
    if (cmp(fromStringz(armAnimations[i].name), "Wave6fps") == 0) {
      animationIndex = i;
      break;
    }
  }
	// Assign `animArm` to this animation
  ModelAnimation animArm = armAnimations[animationIndex];

	// Create a floor
  Model modelFloor = LoadModelFromMesh(GenMeshCube(120.0f, 0.5f, 120.0f));

	// game loop
  uint frame = 1;
  float animationFrame = 0.0f;
  while (!WindowShouldClose()) {

		// (Slowly) advance the animation, looping when it's finished
    animationFrame += GetFrameTime() * 2.0f;
    while (animationFrame >= animArm.keyframeCount)
      animationFrame -= animArm.keyframeCount;
    UpdateModelAnimation(modelArm, animArm, animationFrame);

    // Upload camera pos and update camera
    SetShaderValue(shader, shader.locs[rlShaderLocationIndex.RL_SHADER_LOC_VECTOR_VIEW], &camera.position.x, rlShaderUniformDataType.RL_SHADER_UNIFORM_VEC3);
    updateCamera(camera, moveSpeed, mouseSensitivity);

    BeginDrawing();
      ClearBackground(Colors.BLACK);
      BeginMode3D(camera);
        DrawModel(modelFloor, Vector3(0, -1, 0), 1.0f, DARKGRAY);
        DrawModel(modelArm, Vector3.zero, 1.0f, Colors.WHITE);
      EndMode3D();
      DrawFPS(10, 10);
    EndDrawing();

    // End of frame
    frame++;
  }

	// Cleanup
	UnloadModel(modelArm);
	UnloadModel(modelFloor);
  UnloadModelAnimations(armAnimations, armAnimationCount);
	CloseWindow();
  return 0;
}
