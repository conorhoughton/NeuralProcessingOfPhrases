#https://jakevdp.github.io/PythonDataScienceHandbook/04.12-three-dimensional-plotting.html

from mpl_toolkits import mplot3d
import numpy as np
import matplotlib.pyplot as plt

from scipy.stats import gamma

def f(x, y):
    return gamma.pdf(np.sqrt(x ** 2 + y ** 2),2.0)

# x = np.linspace(-6, 6, 100)
# y = np.linspace(-6, 6, 100)

# X, Y = np.meshgrid(x, y)
# Z = f(X, Y)
# fig = plt.figure()
# ax = plt.axes(projection='3d')
# ax.contour3D(X, Y, Z, 50, cmap='binary')
# #ax.plot_wireframe(X, Y, Z, color='black')
# ax.set_xlabel('x')
# ax.set_ylabel('y')
# ax.set_zlabel('z');

# plt.show()

r = np.linspace(0, 8, 120)
theta = np.linspace(-1.0 * np.pi, 0.7 * np.pi, 40)
r, theta = np.meshgrid(r, theta)

X = r * np.sin(theta)
Y = r * np.cos(theta)
Z = f(X, Y)

ax = plt.axes(projection='3d')
ax.set_axis_off()
ax.plot_surface(X, Y, Z, rstride=1, cstride=1, cmap='viridis', edgecolor='none');
ax.axes.get_xaxis().set_visible(False)
ax.axes.get_yaxis().set_visible(False)
ax.axes.get_zaxis().set_visible(False)
#plt.xlim([-6,6])
#plt.ylim([-6,6])
plt.savefig("bundt.png",transparent=True)
plt.show()
