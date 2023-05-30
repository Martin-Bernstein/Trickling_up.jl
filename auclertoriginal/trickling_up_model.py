import numpy as np
import matplotlib.pyplot as plt
from scipy import linalg

def simulate_baseline(a0, m, theta, ts, ge=True):
    # define matrix B so that adot = Ba, use matrix exponential as solution for each t
    # not the most efficient approach, but fine for this purpose
    B = -np.diag(m) + np.outer(ge*theta, m)
    a = np.stack([linalg.expm(t*B) @ a0 for t in ts], axis=-1)
    
    # return N*T matrix giving asset ("excess savings") path, T vector giving agg C
    return a, m @ a

ts = np.linspace(0, 300, 500)

#Baseline calibration
a0     =  np.array([0.6, 0.3, 0.1])     # Initial excess savings shares
theta  =  np.array([0.47, 0.38, 0.15])  # Income shares, must add to 1!
mpcs   =  np.array([0.4, 0.2, 0])       # Quarterly MPCs 
m      =  -np.log(1-mpcs)               # Convert to continuous time
labels = ['Bottom 80%', 'Next 19%', 'Top 1%']

#Baseline simulation
a, C = simulate_baseline(a0, m, theta, ts)
#Partial equilibrium, baseline
a_pe, C_pe = simulate_baseline(a0, m, theta, ts, ge=False)


#Rational expectations extension
def simulate_re(a0, m, theta, ts):
    # drop last type (assume Ricardian), remember total assets
    atotal = a0.sum()
    a0, m, theta = a0[:-1], m[:-1], theta[:-1]
    
    # build A matrix
    N = len(m)
    A = np.block([[np.zeros((N,N)), -np.eye(N)+ np.outer(theta, np.ones(N))],
                  [np.diag(-m**2),  np.zeros((N,N))]])

    # obtain solution: adot = B*a, c = F*a
    B, F = solver(A, N)
    a = np.stack([linalg.expm(t*B) @ a0 for t in ts], axis=-1)
    C = F.sum(axis=0) @ a
    
    # add back final type's assets
    a = np.row_stack((a, atotal - a.sum(axis=0)))
    
    return a, C

a_re, C_re = simulate_re(a0, m, theta, ts)

#Monetary policy extension
def simulate_monetary(a0, sigma, m, theta, phi, ts):
    # build A matrix
    N = len(m)
    A = np.block([[np.outer(theta, m) - np.diag(m), np.outer(theta, np.ones(N)) - np.eye(N)],
                  [phi/sigma*np.outer(theta, m),    np.diag(m) + phi/sigma*np.outer(theta, np.ones(N))]])
    
    # delete row and column for Ricardian assets to avoid unit root (doesn't affect spending)
    A = np.delete(A, N-1, axis=0)
    A = np.delete(A, N-1, axis=1)
    
    # obtain solution: adot = B*a, cP = F*a, c = cP + m'a
    B, F = solver(A, N-1)
    a = np.stack([linalg.expm(t*B) @ a0[:-1] for t in ts], axis=-1)
    C = (F.sum(axis=0) + m[:-1]) @ a
    
    # add back final type's assets
    a = np.row_stack((a, a0.sum() - a.sum(axis=0)))
    
    return a, C

#Monetary policy simulation
a_mp, C_mp = simulate_monetary(a0, 1/0.5, m, theta, 1.5, ts)


level = 6.7 # Excess savings in 2022Q1 = 6.7% of GDP


##For table 1: Simpson's rule
def simpson_weights(T):
    # get equispaced Simpson weights of 1, 4, 2, 4, 2, ..., 4, 1 all divided by 3
    assert T % 2 == 1, 'must have odd # of points, even # of intervals for standard Simpson rule'
    weights = 2 + 2*(np.arange(T) % 2 == 1)
    weights[0] -= 1
    weights[-1] -= 1
    return weights / 3

def simpson(y, x):
    # Integrate y(x) using Simpson's rule, assuming x is equispaced
    # could use scipy.integrate.simpson, but that was added recently
    T = len(x)
    if T % 2 == 1:
        # standard case with odd # of points, even # of intervals
        return (x[1] - x[0])*np.dot(simpson_weights(T), y)
    else:
        # even # of points, odd # of intervals, use Simpson's 3/8 rule on final 3 intervals as fix
        final_weights = (3/8)*np.array([1, 3, 3, 1])
        return (x[1] - x[0])*(np.dot(simpson_weights(T-3), y[:-3]) + np.dot(final_weights, y[-4:]))

#Duration formula
def duration(X):
    return simpson(X*ts, ts) / simpson(X, ts)

#Rows of table 1:
print(f' PE C           = {duration(C_pe):.0f} Q  | a0 = {duration(a_pe[0]):.0f} Q  | a1 = {duration(a_pe[1]):.0f} Q') 
print(f' Benchmark C    = {duration(C):.0f} Q | a0 = {duration(a[0]):.0f} Q | a1 = {duration(a[1]):.0f} Q ') 
print(f' Scenario #1 C  = {duration(C1):.0f} Q | a0 = {duration(a1[0]):.0f} Q | a1 = {duration(a1[1]):.0f} Q  ') 
print(f' Scenario #2 C  = {duration(C2):.0f} Q | a0 = {duration(a2[0]):.0f} Q | a1 = {duration(a2[1]):.0f} Q  ') 
print(f' Scenario #3 C  = {duration(C3):.0f} Q | a0 = {duration(a3[0]):.0f} Q | a1 = {duration(a3[1]):.0f} Q ') 
print(f' Rational E C   = {duration(C_re):.0f} Q  | a0 = {duration(a_re[0]):.0f} Q  | a1 = {duration(a_re[1]):.0f} Q ') 
print(f' Tight mp C     = {duration(C_mp):.0f} Q  | a0 = {duration(a_mp[0]):.0f} Q  | a1 = {duration(a_mp[1]):.0f} Q') 

#Figure 4
fig, ax1 = plt.subplots(2,2,figsize=(12,6))

ax1[0,0].stackplot(ts, level*a_pe[2], level*a_pe[1], level*a_pe[0],  labels = labels[::-1], colors=['k', '#666666', '#CCCCCC']) 
ax1[0,0].set_ylabel('Percent of GDP')
ax1[0,0].set_title('Excess savings: partial equilibrium')
ax1[0,0].set_xlim(0,40)
ax1[0,0].set_xlabel('Quarters')
# Reverse legend order for readability
handles, labels = ax1[0,0].get_legend_handles_labels()
ax1[0,0].legend(handles[::-1], labels[::-1], loc='upper right', framealpha=0)

ax1[0,1].stackplot(ts, level*a[2], level*a[1],level*a[0], colors=['k', '#666666', '#CCCCCC']) 
ax1[0,1].set_ylabel('Percent of GDP')
ax1[0,1].set_title('Excess savings: easy monetary policy')
ax1[0,1].set_xlabel('Quarters')
ax1[0,1].set_xlim(0,40)

ax1[1,0].stackplot(ts, level*a_mp[2], level*a_mp[1],level*a_mp[0], colors=['k', '#666666', '#CCCCCC']) 
ax1[1,0].set_ylabel('Percent of GDP')
ax1[1,0].set_title('Excess savings: tight monetary policy')
ax1[1,0].set_xlabel('Quarters')
ax1[1,0].set_xlim(0,40)

ax1[1,1].plot(ts, level*C_pe, linewidth = 2, label='Partial equilibrium', color='k')
ax1[1,1].plot(ts, level*C, linewidth = 2, label='Easy monetary policy', color='k', linestyle=':')
ax1[1,1].plot(ts, level*C_mp, linewidth = 2, label='Tight monetary policy', color='k', linestyle='--')
ax1[1,1].tick_params(axis='both', which='major') 
ax1[1,1].legend(framealpha=0)
ax1[1,1].set_title('Consumption')
ax1[1,1].set_ylabel('Percent of GDP')
ax1[1,1].set_xlabel('Quarters')
ax1[1,1].set_xlim(0,40)

plt.tight_layout();
plt.savefig(f'Figure4.pdf', transparent=True);
