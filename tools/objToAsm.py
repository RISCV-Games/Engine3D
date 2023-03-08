from __future__ import annotations
from dataclasses import dataclass
import os
import sys


@dataclass(frozen=True)
class Vertex:
    x: float
    y: float
    z: float

@dataclass(frozen=True)
class Face:
    a: int
    b: int
    c: int

@dataclass(frozen=True)
class Mesh:
    vertices: list[Vertex]
    faces: list[Face]

    @staticmethod
    def from_string(content: str) -> Mesh:
        vertices = []
        faces = []

        def add_vertex(points: list[str]) -> None:
            f_points = [float(p) for p in points if p.strip()]
            vertices.append(
                    Vertex(x=f_points[0], y=f_points[1], z=f_points[2]))

        def add_face(indexes: list[str]) -> None:
            i_indexes = [int(i) - 1 for i in indexes if i.strip()]
            faces.append(
                    Face(a=i_indexes[0], b=i_indexes[1], c=i_indexes[2]))

        lines = [
                line.strip()
                for line in content.split("\n")
                if (line.strip() and 
                    not line.strip().startswith("#"))
                ]

        for line in lines:
            option = line.split(" ")[0]
            if option == "v":
                points = line.split(" ")[1:]
                add_vertex(points)

            elif option == "f":
                points = line.split(" ")[1:]
                add_face(points)

        return Mesh(vertices=vertices, faces=faces)

    def dump_to_asm(self, file_path: str, name: str) -> None:
        v_str = ",".join([f"{v.x},{v.y},{v.z}" for v in self.vertices])
        vertices_str = f"MESH_VERT: .float {v_str}\n"

        f_str = ",".join([f"{f.a},{f.b},{f.c}" for f in self.faces])
        faces_str = f"MESH_FACE: .word {f_str}\n"
        size_str =  f"MESH_SIZE: .word {len(self.faces)}\n"

        with open(file_path, "w") as f:
            f.write(".align 2\n")
            f.write(size_str)
            f.write(vertices_str)
            f.write(faces_str)

    @staticmethod
    def normalized(mesh: Mesh) -> Mesh:
        def normalize_range(
                num: float, 
                old_min: float, old_max: float, 
                new_min: float, new_max: float,
                scaler: float) -> float:

            if (old_max - old_min) == 0:
                return (new_min+new_max)/2

            return ((
                    (new_max - new_min)*(num - old_min)/(old_max - old_min)
                   ) + new_min) *scaler 

        max_x = max(v.x for v in mesh.vertices)
        min_x = min(v.x for v in mesh.vertices)
        max_y = max(v.y for v in mesh.vertices)
        min_y = min(v.y for v in mesh.vertices)
        max_z = max(v.z for v in mesh.vertices)
        min_z = min(v.z for v in mesh.vertices)

        normalize_x = lambda num: normalize_range(num, min_x, max_x, -1, 1, 0.5)
        normalize_y = lambda num: normalize_range(num, min_y, max_y, -1, 1, 0.5)
        normalize_z = lambda num: normalize_range(num, min_z, max_z, -1, 1, 0.5)

        return Mesh(
                vertices=[
                    Vertex(x=normalize_x(v.x), y=normalize_y(v.y), z=normalize_z(v.z))
                    for v in mesh.vertices
                    ],
                faces=mesh.faces
                )

def load_file(file_path: str) -> str:
    with open(file_path, "r") as f:
        content = f.read()

    return content

def usage() -> None:
    print("USAGE:")
    print("     python objToAsm.py <input_path> <output_path>")

def get_relative_name(file_path: str) -> str:
    return "".join(
            file_path.split(os.sep)[-1]
            .split(".")[:-1]
        )

def main():
    if len(sys.argv) < 3:
        usage()
        exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]
    name = get_relative_name(output_path)

    content = load_file(input_path)
    mesh = Mesh.from_string(content)

    n_mesh = Mesh.normalized(mesh)
    n_mesh.dump_to_asm(output_path, name)


if __name__ == "__main__":
    main()
