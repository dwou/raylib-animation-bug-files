#include "raylib.h"
#include "stdlib.h"
#include "resource_dir.h"
#include <string.h>
#include <stdio.h>


// WASD + Ctrl + Space movement
void updateCamera(
  Camera3D* camera,
  float moveSpeed,
  float mouseSensitivity
) {
  Vector3 movement = (Vector3){0, 0, 0};
  Vector3 rotation = (Vector3){0, 0, 0};
  float step = moveSpeed * GetFrameTime();
  if (IsKeyDown(KEY_W)) movement.x += step;
  if (IsKeyDown(KEY_S)) movement.x -= step;
  if (IsKeyDown(KEY_D)) movement.y += step;
  if (IsKeyDown(KEY_A)) movement.y -= step;
  if (IsKeyDown(KEY_SPACE)) movement.z += step;
  if (IsKeyDown(KEY_LEFT_CONTROL)) movement.z -= step;
  rotation.x = GetMouseDelta().x * mouseSensitivity;
  rotation.y = GetMouseDelta().y * mouseSensitivity;
  UpdateCameraPro(camera, movement, rotation, 0.0f);
}


int main () {
	// Pre-window init variables
	const float moveSpeed = 25;
	const float mouseSensitivity = 0.05f;
  Camera3D camera = (Camera3D){
    (Vector3){10, 5, 0},
    (Vector3){0, 5, 5},
    (Vector3){0.0f, 1.0f, 0.0f},
    90.0f,
    CAMERA_PERSPECTIVE
	};

	// Window init
	InitWindow(896, 560, "C project");
	SetTargetFPS(24);
	DisableCursor();

	SearchAndSetResourceDir("resources");

	// Load default shader
  Shader shader = LoadShader(0, 0);

	// Load model and animations
  Model modelArm = LoadModel("wave.glb");
  int armAnimationCount = 0;
  ModelAnimation* armAnimations = LoadModelAnimations("wave.glb", &armAnimationCount);
	// Find the index of the desired animation
  int animationIndex;
  for (int i = 0; i <= armAnimationCount; i++) {
    if (armAnimationCount == i) exit(1);
    if (strcmp(armAnimations[i].name, "Wave6fps") == 0) {
      animationIndex = i;
      break;
    }
  }
	// Assign `animArm` to this animation
  ModelAnimation animArm = armAnimations[animationIndex];

	// Create a floor
  Model modelFloor = LoadModelFromMesh(GenMeshCube(120.0f, 0.5f, 120.0f));

	// game loop
  int frame = 1;
  float animationFrame = 0.0f;
	while (!WindowShouldClose()) {
		// (Slowly) advance the animation, looping when it's finished
    animationFrame += GetFrameTime() * 2.0f;
    while (animationFrame >= animArm.keyframeCount)
      animationFrame -= animArm.keyframeCount;
		printf("animationFrame: %f\n", animationFrame);
    UpdateModelAnimation(modelArm, animArm, animationFrame);

    // Upload camera pos and update camera
    SetShaderValue(shader, shader.locs[SHADER_LOC_VECTOR_VIEW], &camera.position.x, SHADER_UNIFORM_VEC3);
    updateCamera(&camera, moveSpeed, mouseSensitivity);

    BeginDrawing();
      ClearBackground(BLACK);
      BeginMode3D(camera);
        DrawModel(modelFloor, (Vector3){0, -1, 0}, 1.0f, DARKGRAY);
        DrawModel(modelArm, (Vector3){0, 0, 0}, 1.0f, WHITE);
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
