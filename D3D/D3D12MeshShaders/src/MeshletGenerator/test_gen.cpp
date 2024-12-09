#define CATCH_CONFIG_MAIN
#include "catch.hpp"
#include "Generation.h"
#include <DirectXMath.h>
#include <vector>

using namespace DirectX;

TEST_CASE("AddToMeshlet function works correctly", "[AddToMeshlet]") {
    const uint32_t maxVerts = 10;
    const uint32_t maxPrims = 5;
    InlineMeshlet<uint32_t> meshlet;
    uint32_t tri[3] = {0, 1, 2};

    SECTION("Adding a triangle to an empty meshlet") {
        bool result = AddToMeshlet(maxVerts, maxPrims, meshlet, tri);
        REQUIRE(result == true);
        REQUIRE(meshlet.UniqueVertexIndices.size() == 3);
        REQUIRE(meshlet.PrimitiveIndices.size() == 1);
    }

    SECTION("Adding a triangle that exceeds maxVerts") {
        for (uint32_t i = 0; i < maxVerts; ++i) {
            meshlet.UniqueVertexIndices.push_back(i);
        }
        bool result = AddToMeshlet(maxVerts, maxPrims, meshlet, tri);
        REQUIRE(result == false);
    }

    SECTION("Adding a triangle that exceeds maxPrims") {
        for (uint32_t i = 0; i < maxPrims; ++i) {
            typename InlineMeshlet<uint32_t>::PackedTriangle prim = {i, i+1, i+2};
            meshlet.PrimitiveIndices.push_back(prim);
        }
        bool result = AddToMeshlet(maxVerts, maxPrims, meshlet, tri);
        REQUIRE(result == false);
    }
}

TEST_CASE("ComputeReuse function works correctly", "[ComputeReuse]") {
    InlineMeshlet<uint32_t> meshlet;
    uint32_t triIndices[3] = {0, 1, 2};

    SECTION("No reuse") {
        uint32_t reuse = ComputeReuse(meshlet, triIndices);
        REQUIRE(reuse == 0);
    }

    SECTION("Partial reuse") {
        meshlet.UniqueVertexIndices.push_back(0);
        uint32_t reuse = ComputeReuse(meshlet, triIndices);
        REQUIRE(reuse == 1);
    }

    SECTION("Full reuse") {
        meshlet.UniqueVertexIndices.push_back(0);
        meshlet.UniqueVertexIndices.push_back(1);
        meshlet.UniqueVertexIndices.push_back(2);
        uint32_t reuse = ComputeReuse(meshlet, triIndices);
        REQUIRE(reuse == 3);
    }
}