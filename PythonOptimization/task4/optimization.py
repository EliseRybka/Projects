from collections import defaultdict
import numpy as np
from numpy.linalg import norm
from time import time
from datetime import datetime
import math


def subgradient_method(oracle, x_0, tolerance=1e-2, max_iter=1000, alpha_0=1,
                       display=False, trace=False):
    """
    Subgradient descent method for nonsmooth convex optimization.

    Parameters
    ----------
    oracle : BaseNonsmoothConvexOracle-descendant object
        Oracle with .func() and .subgrad() methods implemented for computing
        function value and its one (arbitrary) subgradient respectively.
        If available, .duality_gap() method is used for estimating f_k - f*.
    x_0 : 1-dimensional np.array
        Starting point of the algorithm
    tolerance : float
        Epsilon value for stopping criterion.
    max_iter : int
        Maximum number of iterations.
    alpha_0 : float
        Initial value for the sequence of step-sizes.
    display : bool
        If True, debug information is displayed during optimization.
        Printing format is up to a student and is not checked in any way.
    trace:  bool
        If True, the progress information is appended into history dictionary during training.
        Otherwise None is returned instead of history.

    Returns
    -------
    x_star : np.array
        The point found by the optimization procedure
    message : string
        'success' or the description of error:
            - 'iterations_exceeded': if after max_iter iterations of the method x_k still doesn't satisfy
              the stopping criterion.
    history : dictionary of lists or None
        Dictionary containing the progress information or None if trace=False.
        Dictionary has to be organized as follows:
            - history['func'] : list of function values phi(x_k) on every step of the algorithm
            - history['time'] : list of floats, containing time in seconds passed from the start of the method
            - history['duality_gap'] : list of duality gaps
            - history['x'] : list of np.arrays, containing the trajectory of the algorithm. ONLY STORE IF x.size <= 2
    """
    # TODO: implement.
    history = defaultdict(list) if trace else None
    start_time = None
    
    x_k = x_0
    x_star = x_k
    f_star = oracle.func(x_k)
    
    if display: print("Some info")
    
    #Starting iterations
    for k in range(max_iter + 1):
        
        #initializing
        f_k = oracle.func(x_k)
        sg_k = oracle.subgrad(x_k)
        dg_k = oracle.duality_gap(x_k)
        
        #history update
        if trace:
            if start_time is None: start_time = datetime.now()
            if x_k.size <= 2:
                    history['x'].append(x_k)
            history['func'].append(f_k)
            history['time'].append((datetime.now() - start_time).total_seconds())
            history['duality_gap'].append(dg_k)
        
        #Star update
        if f_k < f_star:
            f_star = f_k
            x_star = x_k
            
        #Stop criterion
        if dg_k <= tolerance:
            return x_star, 'success', history
            
        #iteration
        alpha_k = alpha_0 / math.sqrt(k + 1)
        x_k = x_k + alpha_k * ( -sg_k / norm(sg_k) )
        
    return x_star, 'iterations_exceeded', history
    


def proximal_gradient_descent(oracle, x_0, L_0=1, tolerance=1e-5,
                              max_iter=1000, trace=False, display=False):
    """
    Proximal gradient descent for composite optimization.

    Parameters
    ----------
    oracle : BaseCompositeOracle-descendant object
        Oracle with .func() and .grad() and .prox() methods implemented 
        for computing function value, its gradient and proximal mapping 
        respectively.
        If available, .duality_gap() method is used for estimating f_k - f*.
    x_0 : 1-dimensional np.array
        Starting point of the algorithm
    L_0 : float
        Initial value for adaptive line-search.
    tolerance : float
        Epsilon value for stopping criterion.
    max_iter : int
        Maximum number of iterations.
    display : bool
        If True, debug information is displayed during optimization.
        Printing format is up to a student and is not checked in any way.
    trace:  bool
        If True, the progress information is appended into history dictionary during training.
        Otherwise None is returned instead of history.

    Returns
    -------
    x_star : np.array
        The point found by the optimization procedure
    message : string
        'success' or the description of error:
            - 'iterations_exceeded': if after max_iter iterations of the method x_k still doesn't satisfy
              the stopping criterion.
    history : dictionary of lists or None
        Dictionary containing the progress information or None if trace=False.
        Dictionary has to be organized as follows:
            - history['func'] : list of function values phi(x_k) on every step of the algorithm
            - history['time'] : list of floats, containing time in seconds passed from the start of the method
            - history['duality_gap'] : list of duality gaps
            - history['x'] : list of np.arrays, containing the trajectory of the algorithm. ONLY STORE IF x.size <= 2
    """
    # TODO: implement.
    
    history = defaultdict(list) if trace else None
    start_time = None
    ls_iter= 0
    
    L = L_0
    x_k = x_0
    x_star = x_k
    phi_star = oracle.func(x_k)
    
    if display: print("Some info")
    
    for k in range(max_iter + 1):
        
        #initializing
        phi_k = oracle.func(x_k)
        f_k = oracle._f.func(x_k)
        g_k = oracle.grad(x_k)
        dg_k = oracle.duality_gap(x_k)
        
        #history update
        if trace:
            if start_time is None: start_time = datetime.now()
            if x_k.size <= 2:
                    history['x'].append(x_k)
            history['func'].append(phi_k)
            history['time'].append((datetime.now() - start_time).total_seconds())
            history['duality_gap'].append(dg_k)
            history['linear_search_iterations'].append(ls_iter)
        
        #Star update
        if phi_k < phi_star:
            phi_star = phi_k
            x_star = x_k
            
        #stopping criterion
        if dg_k <= tolerance:
            return x_star, 'success', history
        
        #iteration
        while True:
            y = oracle.prox(x_k - 1 / L * g_k, 1 / L)
            ls_iter += 1
            if oracle._f.func(y) <= f_k + g_k.dot(y - x_k) + L / 2 * (y - x_k).dot(y - x_k):
                break
            L = 2 * L 
            
        x_k = y
        L = max(L_0, L / 2)
        
    return x_star, 'iterations_exceeded', history


def accelerated_proximal_gradient_descent(oracle, x_0, L_0=1.0, tolerance=1e-5,
                              max_iter=1000, trace=False, display=False):
    """
    Proximal gradient descent for composite optimization.

    Parameters
    ----------
    oracle : BaseCompositeOracle-descendant object
        Oracle with .func() and .grad() and .prox() methods implemented 
        for computing function value, its gradient and proximal mapping 
        respectively.
        If available, .duality_gap() method is used for estimating f_k - f*.
    x_0 : 1-dimensional np.array
        Starting point of the algorithm
    L_0 : float
        Initial value for adaptive line-search.
    tolerance : float
        Epsilon value for stopping criterion.
    max_iter : int
        Maximum number of iterations.
    display : bool
        If True, debug information is displayed during optimization.
        Printing format is up to a student and is not checked in any way.
    trace:  bool
        If True, the progress information is appended into history dictionary during training.
        Otherwise None is returned instead of history.

    Returns
    -------
    x_star : np.array
        The point found by the optimization procedure
    message : string
        'success' or the description of error:
            - 'iterations_exceeded': if after max_iter iterations of the method x_k still doesn't satisfy
              the stopping criterion.
    history : dictionary of lists or None
        Dictionary containing the progress information or None if trace=False.
        Dictionary has to be organized as follows:
            - history['func'] : list of function values phi(y_k) on every step of the algorithm
            - history['time'] : list of floats, containing time in seconds passed from the start of the method
            - history['duality_gap'] : list of duality gaps
    """
    # TODO: Implement
    history = defaultdict(list) if trace else None
    start_time = None
    
    x_star = x_0
    func_star = oracle.func(x_star)
    
    L_k = L_0
    A_k_1 = 0
    y_k_1 = np.copy(x_0)
    v_k_1 = np.copy(x_0)
    z_k_1 = np.copy(x_0)
    
    grad_sum = 0.0
    ls_iter = 0
    
    if display: print("Some info")
    
    
    for i in range(max_iter + 1):
        
        #initializing
        dg_k = oracle.duality_gap(y_k_1)
        func_y_k = oracle.func(y_k_1)
        func_z_k = oracle.func(z_k_1)
        
        if func_y_k < func_star:
            func_star = func_y_k
            x_star = y_k_1
        if func_z_k < func_star:
            func_star = func_z_k
            x_star = z_k_1
        
        # History update
        if trace:
            if start_time is None: start_time = datetime.now()
            if y_k_1.size <= 2:
                    history['x'].append(y_k_1)
            history['func'].append(func_y_k)
            history['time'].append((datetime.now() - start_time).total_seconds())
            history['duality_gap'].append(dg_k)
            history['linear_search_iterations'].append(ls_iter)
        

        # Stopping criterion
        if dg_k < tolerance:
            return x_star, 'success', history
        
        
        #iteration
        while (True):
            ls_iter += 2 #as we do twice as much oracle calls
            
            a = (1 + (1 + 4 * L_k * A_k_1) ** 0.5) / (2 * L_k)
            t = a / (a + A_k_1)
            z = t * v_k_1 + (1 - t) * y_k_1
            
            grad_z = oracle.grad(z)
            func_z = oracle._f.func(z)
            
            alpha_k = 1 / L_k
            y = oracle.prox(z - alpha_k * grad_z, alpha_k)
            
            func_y =  oracle._f.func(y)
            
            if (func_y < func_z + grad_z.dot(y - z) + L_k * (norm(y - z) ** 2) / 2):
                break
            
            L_k = 2 * L_k
        a_k = a
        A_k_1 = A_k_1 + a_k
        y_k_1 = y
        z_k_1 = z
        
        grad_sum += a_k * grad_z
        v_k_1 = oracle.prox(x_0 - grad_sum, A_k_1)
        L_k = max(L_k / 2, L_0)

    return x_star, 'iterations_exceeded', history

