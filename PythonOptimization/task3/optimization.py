from collections import defaultdict
import numpy as np
from numpy.linalg import norm, solve
from time import time
from datetime import datetime

import oracles
import math
import scipy


def computational_error(x):
    if (x is None) or math.isinf(x):
        return True
    return False

def computational_error_for_matr(X):
    return (np.any(np.isnan(X)) or (not np.any(np.isfinite(X))))
    



def armijo_lineSearch(oracle, alpha_0, x_k, u_k, d_k, t, c1):
    alpha = alpha_0
    f0 = oracle.func(x_k, u_k, t)
    df_k0 = oracle.grad_directional(x_k, u_k, t, d_k, 0)
    while (oracle.func_directional(x_k, u_k, t, d_k, alpha) > f0 + c1 * alpha * df_k0):
        alpha /= 2
    return alpha


def barrier_method_lasso(A, b, reg_coef, x_0, u_0, tolerance=1e-5, 
                         tolerance_inner=1e-8, max_iter=100, 
                         max_iter_inner=20, t_0=1, gamma=10, 
                         c1=1e-4, lasso_duality_gap=None,
                         trace=False, display=False):
    """
    Log-barrier method for solving the problem:
        minimize    f(x, u) := 1/2 * ||Ax - b||_2^2 + reg_coef * \sum_i u_i
        subject to  -u_i <= x_i <= u_i.

    The method constructs the following barrier-approximation of the problem:
        phi_t(x, u) := t * f(x, u) - sum_i( log(u_i + x_i) + log(u_i - x_i) )
    and minimize it as unconstrained problem by Newton's method.

    In the outer loop `t` is increased and we have a sequence of approximations
        { phi_t(x, u) } and solutions { (x_t, u_t)^{*} } which converges in `t`
    to the solution of the original problem.

    Parameters
    ----------
    A : np.array
        Feature matrix for the regression problem.
    b : np.array
        Given vector of responses.
    reg_coef : float
        Regularization coefficient.
    x_0 : np.array
        Starting value for x in optimization algorithm.
    u_0 : np.array
        Starting value for u in optimization algorithm.
    tolerance : float
        Epsilon value for the outer loop stopping criterion:
        Stop the outer loop (which iterates over `k`) when
            `duality_gap(x_k) <= tolerance`
    tolerance_inner : float
        Epsilon value for the inner loop stopping criterion.
        Stop the inner loop (which iterates over `l`) when
            `|| \nabla phi_t(x_k^l) ||_2^2 <= tolerance_inner * \| \nabla \phi_t(x_k) \|_2^2 `
    max_iter : int
        Maximum number of iterations for interior point method.
    max_iter_inner : int
        Maximum number of iterations for inner Newton's method.
    t_0 : float
        Starting value for `t`.
    gamma : float
        Multiplier for changing `t` during the iterations:
        t_{k + 1} = gamma * t_k.
    c1 : float
        Armijo's constant for line search in Newton's method.
    lasso_duality_gap : callable object or None.
        If calable the signature is lasso_duality_gap(x, Ax_b, ATAx_b, b, regcoef)
        Returns duality gap value for esimating the progress of method.
    trace : bool
        If True, the progress information is appended into history dictionary 
        during training. Otherwise None is returned instead of history.
    display : bool
        If True, debug information is displayed during optimization.
        Printing format is up to a student and is not checked in any way.

    Returns
    -------
    (x_star, u_star) : tuple of np.array
        The point found by the optimization procedure.
    message : string
        "success" or the description of error:
            - 'iterations_exceeded': if after max_iter iterations of the method x_k still doesn't satisfy
                the stopping criterion.
            - 'computational_error': in case of getting Infinity or None value during the computations.
    history : dictionary of lists or None
        Dictionary containing the progress information or None if trace=False.
        Dictionary has to be organized as follows:
            - history['time'] : list of floats, containing time in seconds passed from the start of the method
            - history['func'] : list of function values f(x_k) on every **outer** iteration of the algorithm
            - history['duality_gap'] : list of duality gaps
            - history['x'] : list of np.arrays, containing the trajectory of the algorithm. ONLY STORE IF x.size <= 2
    """
    # TODO: implement.
    history = defaultdict(list) if trace else None
    x_k = np.copy(x_0)
    u_k = np.copy(u_0)
    t = t_0
    
    oracle = oracles.LassoBarrierOracle(A, b, reg_coef)
    eps_due_to_float = 1e-8
    start_time = None
    flag_precision_linalg_errors_started = False
    
    for outer_i in range(0, max_iter + 1):
        
        #history update (outer)
        if trace:
            if start_time is None: start_time = datetime.now()
            
            f_k = oracle.func(x_k, u_k, t)
            
            if lasso_duality_gap is None:
                duality_gap = None
            else: duality_gap = lasso_duality_gap(x_k, oracle.matvec_Ax_b(x_k), oracle.matmatvec_ATAx_b(x_k), b, reg_coef)
            
            if x_k.size + u_k.size <= 2:
                    history['x'].append((x_k, u_k))
            history['func'].append(f_k)
            history['time'].append((datetime.now() - start_time).total_seconds())
            history['duality_gap'].append(duality_gap)
        
        #Stoping Criteria
        #Check if quality gap is already small enough
        if (lasso_duality_gap(x_k, oracle.matvec_Ax_b(x_k), oracle.matmatvec_ATAx_b(x_k), b, reg_coef) < tolerance):
            return [(x_k, u_k), 'success', history]
        
        
        
        # Preparing for inner Newton's method. Precalculating for stoping criteria 
        grad_f_0 = oracle.grad(x_k, u_k, t)
        grad_f_0_norm = np.linalg.norm(grad_f_0)
        #Checking that no computational error has acquired
        if (computational_error(grad_f_0_norm)): return [(x_k, u_k), 'computational_error', history]
        
        #Starting inner Newton's method.
        for inner_i in range(0, max_iter_inner + 1):
            
            f_k = oracle.func(x_k, u_k, t)
            if (computational_error_for_matr(f_k)): return [(x_k, u_k), 'computational_error', history]
            
            grad_f_k = oracle.grad(x_k, u_k, t)
            grad_f_k_norm = np.linalg.norm(grad_f_k)
            if (computational_error(grad_f_k_norm)): return [(x_k, u_k), 'computational_error', history]
            
            #Displaying information
            if(display): print("some info")
            
            
            #History update (inner)
            if trace:
                if start_time is None: start_time = datetime.now()
            
                f_k = oracle.func(x_k, u_k, t)
            
                if lasso_duality_gap is None:
                    duality_gap = None
                else: duality_gap = lasso_duality_gap(x_k, oracle.matvec_Ax_b(x_k), oracle.matmatvec_ATAx_b(x_k), b, reg_coef)
                
                if x_k.size + u_k.size <= 2:
                    history['x_inner'].append((x_k, u_k))
                history['duality_gap_inner'].append(duality_gap)
                history['func_inner'].append(f_k)
                history['time_inner'].append((datetime.now() - start_time).total_seconds())
            
            
            
            
            #Stoping Criteria
            if (grad_f_k_norm**2 < tolerance_inner * grad_f_0_norm**2 + eps_due_to_float): break
            
            
            
            #Cholesky
            try:
                hess_x_k = oracle.hess(x_k, u_k, t)
                if (flag_precision_linalg_errors_started):
                    hess_x_k = hess_x_k + np.diag(np.ones(hess_x_k.shape[0])) * 1e-2
                cholesky_L = scipy.linalg.cholesky(hess_x_k)
            except np.linalg.LinAlgError:
                hess_x_k = hess_x_k + np.diag(np.ones(hess_x_k.shape[0])) * 1e-2
                flag_precision_linalg_errors_started = True
                cholesky_L = scipy.linalg.cholesky(hess_x_k)
            finally:
                d_k = scipy.linalg.cho_solve((cholesky_L, False), -oracle.grad(x_k, u_k, t))

            
            
            
            #alpha_l_max
            [d_x, d_u] = np.split(d_k, 2)
            alpha_to_minimize = [1.0]
            tetha = 0.9
            
            	#for g_1i
            for i in range(0, d_x.shape[0]):
                if (d_x[i] - d_u[i] > 0):
                    alpha_to_minimize.append(tetha * (-(x_k[i] - u_k[i]) / (d_x[i] - d_u[i])))
             	#for g_2i
            for i in range(0, d_x.shape[0]):
                if (-d_x[i] - d_u[i] > 0):
                    alpha_to_minimize.append(tetha * (x_k[i] + u_k[i]) / (-d_x[i] - d_u[i]))
            alpha_l_max = min(alpha_to_minimize)
            
            #alpha_k
            alpha_k = armijo_lineSearch(oracle, alpha_l_max, x_k, u_k, d_k, t, c1)
            if (computational_error(alpha_k)): return [(x_k, u_k), 'computational_error', history]
            
            #update (x_k, u_k)
            pare = np.concatenate((x_k, u_k), axis=0)
            pare = pare + alpha_k * d_k
            x_k, u_k = np.split(pare, 2)
            
            
            
        
        
        t *= gamma 
        
    return [(x_k, u_k), 'iterations_exceeded', history]
    
    
    
    
    
