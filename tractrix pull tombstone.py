# this is an algorithm written for keeping of a running average of a vector, or more precisely, for adjusting a vector that has a length limit, which is often needed for UI stuff, and probably for games as well. It's a perfect, framerate-independent method, where an imperfect method is often good enough. It's slightly unfinished, and untested, I decided to just use the more common inexact method of adding each delta v and renormalizing each frame. But this is all the code you'll need to do it the perfect way if you wanted to. I've done the research for you (my finding was "use a tractrix curve").

# unlike most tractrix models, it is a slack tractrix, where pushing towards the dog wont push the dog away.

# good for keeping track of the average bearing of something over time, using a single vector.
# it models the average bearing as a vector that can't exceed a certain length. You could approximate this by having a high framerate, adding the acceleration vector times the delta to it each frame, then renormalizing its length, but this would be imperfect, the same mouse movement would result in different bearings depending on the framerate. The exact method, which we use here, uses a tractrix curve. It's framerate-independent and correct.
def limiting_pull(v: tuple[float, float], pull: tuple[float, float], limit: float) -> tuple[float, float]:
    prospective_result = v + pull
    if magnitude(prospective_result) < limit:
        return prospective_result
    # [todo] this is still wrong, sometimes there's an internal movement that isn't minus angle.
    # add another conditional for situations where it's starting from well within the limit circle? but first consider a general "continue this line until it hits the limit" formula (magnitude(v + d*pull) = limit, find d)
    # 
    # then there's a segment of the pull that crosses back through the limit circle, eliminate that, we skip across the circle until it hits the limit
    a = angle_between(v, pull)
    s = sign(a)
    if abs(a) > pi/2:
        aa = abs(a)
        ia = aa - pi/2
        nv = v + angle_to_vector(s*ia*2)*limit
        pull = subtract(pull, subtract(nv, v))
        v = nv
    # what remains will be a tractrix pull
    na = angle_between(pull, v)
    a = angle(pull) + s*tractrix_pull(abs(na), limit, magnitude(pull))
    return angle_to_vector(a)*limit
# angle is the angle of the particle relative to the pull vector, l is the maximum magnitude of the particle vector, distance is the magnitude of this frame's acceleration vector, returns the new angle
def add(a: tuple[float, float], b: tuple[float, float]) -> tuple[float, float]:
    return (a[0] + b[0], a[1] + b[1])
def subtract(a: tuple[float, float], b: tuple[float, float]) -> tuple[float, float]:
    return (a[0] - b[0], a[1] - b[1])
# assumes angle is positive and less than pi/2 and assumes that distance isn't crossing zero (but might work even if it does)
def tractrix_pull(angle: float, limit: float, distance: float) -> float:
    y = limit*sin(angle)
    x = limit*log((limit + sqrt(limit**2 - y**2))/y) - sqrt(limit**2 - y**2)
    p = acosh(1/y)
    np = p + distance
    ny = 1/cosh(np)
    return asin(ny/limit)
def angle(v: tuple[float, float]) -> float:
    return atan2(v[1], v[0])
def magnitude(v: tuple[float, float]) -> float:
    return sqrt(v[0]**2 + v[1]**2)
def sign(x: float) -> int:
    return 1 if x >= 0 else -1
def angle_to_vector(a: float) -> tuple[float, float]:
    return (cos(a), sin(a))
# inside angle from v1 to v2
def angle_between(v1: tuple[float, float], v2: tuple[float, float]) -> float:
    dot = v1[0]*v2[0] + v1[1]*v2[1]
    cross = v1[0]*v2[1] - v1[1]*v2[0]  # 2D cross product (z-component)
    return atan2(cross, dot)



# extracted from scikit-spacial, may contain copy errors
import math
import numpy as np

def line_circle_intersection(
    circle_center: tuple[float, float],
    circle_radius: float,
    line_point: tuple[float, float],
    line_direction: tuple[float, float]
) -> tuple[tuple[float, float], tuple[float, float]] | None:
    """
    Find intersection points of a line with a circle.
    
    Parameters:
    - circle_center: (x, y) center of circle
    - circle_radius: radius of circle
    - line_point: a point on the line (e.g., your origin)
    - line_direction: direction vector of the line (e.g., your 'towards')
    
    Returns:
    - Two intersection points as ((x1, y1), (x2, y2)), or None if no intersection
    """
    # Get two points on the line
    point_1 = np.array(line_point)
    direction_unit = np.array(line_direction) / np.linalg.norm(line_direction)
    point_2 = point_1 + direction_unit
    
    # Translate points so circle is centered at origin
    center = np.array(circle_center)
    point_translated_1 = point_1 - center
    point_translated_2 = point_2 - center
    
    x_1, y_1 = point_translated_1
    x_2, y_2 = point_translated_2
    
    d_x = x_2 - x_1
    d_y = y_2 - y_1
    
    # Compute discriminant
    d_r_squared = d_x**2 + d_y**2
    determinant = x_1 * y_2 - x_2 * y_1
    discriminant = circle_radius**2 * d_r_squared - determinant**2
    
    if discriminant < 0:
        return None  # No intersection
    
    root = math.sqrt(discriminant)
    mp = np.array([-1, 1])  # For computing both solutions
    sign = -1 if d_y < 0 else 1
    
    coords_x = (determinant * d_y + mp * sign * d_x * root) / d_r_squared
    coords_y = (-determinant * d_x + mp * abs(d_y) * root) / d_r_squared
    
    # Translate back to original coordinate system
    point_a = tuple(coords_x[0] + center[0], coords_y[0] + center[1])
    point_b = tuple(coords_x[1] + center[0], coords_y[1] + center[1])
    
    return point_a, point_b

# For your specific use case (ray from origin hitting circle):
def hits_circle_edge_correct(
    origin: tuple[float, float],
    towards: tuple[float, float],
    limit: float
) -> tuple[float, float] | None:
    """Returns the two 'd' values where origin + d*towards hits the circle."""
    result = line_circle_intersection(
        circle_center=(0, 0),
        circle_radius=limit,
        line_point=origin,
        line_direction=towards
    )
    
    if result is None:
        return None
    
    point_a, point_b = result
    
    # Calculate 'd' for each intersection point
    # d = distance from origin to intersection point along 'towards' direction
    towards_norm = np.linalg.norm(towards)
    d1 = np.linalg.norm(np.array(point_a) - np.array(origin)) / towards_norm
    d2 = np.linalg.norm(np.array(point_b) - np.array(origin)) / towards_norm
    
    # Determine sign (positive if in direction of 'towards', negative otherwise)
    vec_to_a = np.array(point_a) - np.array(origin)
    if np.dot(vec_to_a, towards) < 0:
        d1 = -d1
    
    vec_to_b = np.array(point_b) - np.array(origin)
    if np.dot(vec_to_b, towards) < 0:
        d2 = -d2
    
    return (d1, d2)