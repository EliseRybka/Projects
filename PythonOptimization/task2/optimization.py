import numpy as np
from collections import defaultdict, deque  # Use this for effective implementation of L-BFGS
from utils import get_line_search_tool
import math
from datetime import datetime

def conjugate_gradients(matvec, b, x_0, tolerance=1e-4, max_iter=None, trace=False, display=False):
    """
    Solves system Ax=b using Conjugate Gradients method.

    Parameters
    ----------
    matvec : function
        Implement matrix-vector product of matrix A and arbitrary vector x
    b : 1-dimensional np.array
        Vector b for the system.
    x_0 : 1-dimensional np.array
        Starting point of the algorithm
    tolerance : float
        Epsilon value for stopping criterion.
        Stop optimization procedure and return x_k when:
         ||Ax_k - b||_2 <= tolerance * ||b||_2
    max_iter : int, or None
        Maximum number of iterations. if max_iter=None, set max_iter to n, where n is
        the dimension of the space
    trace : bool
        If True, the progress information is appended into history dictionary during training.
        Otherwise None is returned instead of history.
    display:  bool
        If True, debug information is displayed during optimization.
        Printing format is up to a student and is not checked in any way.

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
            - history['time'] : list of floats, containing time in seconds passed from the start of the method
            - history['residual_norm'] : list of values Euclidian norms ||g(x_k)|| of the gradient on every step of the algorithm
            - history['x'] : list of np.arrays, containing the trajectory of the algorithm. ONLY STORE IF x.size <= 2
    """
    history = defaultdict(list) if trace else None
    x_k = np.copy(x_0)
    # Done and checked
    if max_iter is None:
        max_iter = x_k.shape[0]
    
    start_time = None
    eps_due_to_float = 1e-8
    
    g_k = matvec(x_0) - b
    d_k = -g_k
    
    
    for k in range(max_iter + 1):
        if display:
            print("Debug info")
        #Update history
        if trace:
            if start_time is None: start_time = datetime.now()
            if x_k.shape[0] <= 2:
                history['x'].append(x_k)
            history['residual_norm'].append(np.linalg.norm(g_k))
            history['time'].append((datetime.now() - start_time).total_seconds())
        
        #Stoping criteria
        if np.linalg.norm(g_k) < tolerance * np.linalg.norm(b) + eps_due_to_float:
            return x_k, 'success', history
        #Iteration
        Adk = matvec(d_k)
        a = g_k.dot(g_k.T) / Adk.T.dot(d_k.T)
        x_k = x_k + a * d_k
        
        g_kp1 = g_k + Adk.dot(a).T
        d_k = -g_kp1 + g_kp1.dot(g_kp1.T) / g_k.dot(g_k.T) * d_k
        g_k = g_kp1
        
        
    return x_k, 'iterations_exceeded', history


#Дополнительная функция 1
def bfgs_multiply(v, History, gamma_0):
    if len(History) == 0: 
        return gamma_0 * v
    s, y = History[-1]
    Hnew = History[:-1]
    vnew = v - (s.dot(v) / y.dot(s)) * y
    z = bfgs_multiply(vnew, Hnew, gamma_0)
    return z + ((s.dot(v) - y.dot(z)) / y.dot(s)) * s

#Дополнительная функция 2
def lbfgs_direction(dfxk, History):
    if len(History) == 0:
        return -dfxk
    s, y = History[-1]
    gamma_0 = y.dot(s) / y.dot(y)
    return bfgs_multiply(-dfxk, History, gamma_0)




def lbfgs(oracle, x_0, tolerance=1e-4, max_iter=500, memory_size=10,
          line_search_options=None, display=False, trace=False):
    """
    Limited-memory Broyden–Fletcher–Goldfarb–Shanno's method for optimization.

    Parameters
    ----------
    oracle : BaseSmoothOracle-descendant object
        Oracle with .func() and .grad() methods implemented for computing
        function value and its gradient respectively.
    x_0 : 1-dimensional np.array
        Starting point of the algorithm
    tolerance : float
        Epsilon value for stopping criterion.
    max_iter : int
        Maximum number of iterations.
    memory_size : int
        The length of directions history in L-BFGS method.
    line_search_options : dict, LineSearchTool or None
        Dictionary with line search options. See LineSearchTool class for details.
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
            - history['func'] : list of function values f(x_k) on every step of the algorithm
            - history['time'] : list of floats, containing time in seconds passed from the start of the method
            - history['grad_norm'] : list of values Euclidian norms ||g(x_k)|| of the gradient on every step of the algorithm
            - history['x'] : list of np.arrays, containing the trajectory of the algorithm. ONLY STORE IF x.size <= 2
    """
    history = defaultdict(list) if trace else None
    line_search_tool = get_line_search_tool(line_search_options)
    x_k = np.copy(x_0)

    # TODO: Implement L-BFGS method.
    # Use line_search_tool.line_search() for adaptive step size.
    
    History = []
    x_m1 = None
    dfxk_m1 = None
    eps_due_to_float = 1e-8
    start_time = None
    dfx0_norm = np.linalg.norm(oracle.grad(x_0))
    
    for iteration in range(0, max_iter + 1):
        
        
        #initialising
        dfxk = oracle.grad(x_k)
        dfxk_norm = np.linalg.norm(dfxk)
        
        
        
        
        if display: print('Debug information:) Iteration number: ', iteration)
        # History update 							
        if trace:
            if start_time is None: start_time = datetime.now()
            if x_k.shape[0] <= 2:
                history['x'].append(x_k)
            history['grad_norm'].append(dfxk_norm)
            history['func'].append(oracle.func(x_k))
            history['time'].append((datetime.now() - start_time).total_seconds())
        
        #Stop criteria check
        if dfxk_norm < (tolerance ** 0.5) * dfx0_norm + eps_due_to_float:
            return x_k, 'success', history
        
        #FancyHistory update
        if x_m1 is not None and dfxk_m1 is not None:
            History.append((x_k - x_m1, dfxk - dfxk_m1))
            if len(History) > memory_size:
                History = History[1:]
        
        
        #Step
        
        d_k = lbfgs_direction(dfxk, History)
        
        alpha_k = line_search_tool.line_search(oracle, x_k, d_k)
        
        x_m1 = np.copy(x_k)
        dfxk_m1 = np.copy(dfxk)
        x_k = x_k + alpha_k * d_k
        
    
    return x_k, 'iterations_exceeded', history


def hessian_free_newton(oracle, x_0, tolerance=1e-4, max_iter=500, 
                        line_search_options=None, display=False, trace=False):
    """
    Hessian Free method for optimization.

    Parameters
    ----------
    oracle : BaseSmoothOracle-descendant object
        Oracle with .func(), .grad() and .hess_vec() methods implemented for computing
        function value, its gradient and matrix product of the Hessian times vector respectively.
    x_0 : 1-dimensional np.array
        Starting point of the algorithm
    tolerance : float
        Epsilon value for stopping criterion.
    max_iter : int
        Maximum number of iterations.
    line_search_options : dict, LineSearchTool or None
        Dictionary with line search options. See LineSearchTool class for details.
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
            - history['func'] : list of function values f(x_k) on every step of the algorithm
            - history['time'] : list of floats, containing time in seconds passed from the start of the method
            - history['grad_norm'] : list of values Euclidian norms ||g(x_k)|| of the gradient on every step of the algorithm
            - history['x'] : list of np.arrays, containing the trajectory of the algorithm. ONLY STORE IF x.size <= 2
    """
    history = defaultdict(list) if trace else None
    line_search_tool = get_line_search_tool(line_search_options)
    x_k = np.copy(x_0)

    # TODO: Implement hessian-free Newton's method.
    # Use line_search_tool.line_search() for adaptive step size.
    
    
    eps_due_to_float = 1e-8
    start_time = None
    dfx0 = oracle.grad(x_0)
    dfx0_norm2 = dfx0.dot(dfx0.T)
    
    
    for iteration in range(0, max_iter + 1):
        
        dfxk = oracle.grad(x_k)
        dfxk_norm2 = dfxk.dot(dfxk.T)
        # History update
        
        if display: print('Debug information:) Iteration number: ', iteration)

        if trace:
            if start_time is None: start_time = datetime.now()
            if x_k.shape[0] <= 2:
                history['x'].append(x_k)
            history['grad_norm'].append(math.sqrt(dfxk_norm2))
            history['func'].append(oracle.func(x_k))
            history['time'].append((datetime.now() - start_time).total_seconds())
        
        #Stoping criteria check
        if (dfxk_norm2 < tolerance * dfx0_norm2 + eps_due_to_float):
            return x_k, 'success', history
        
        n_k = min(0.5, (dfxk_norm2) ** 0.25)
        d_start = - dfxk
        matvec = lambda x: oracle.hess_vec(x_k, x.T)
        while True:
            # find d_k through cg
            
            d_k, message, history_sg = conjugate_gradients(matvec, -dfxk, d_start, tolerance=n_k, max_iter=None, trace=False, display=False)
            
            
            #Check if cg made d_k descent direction
            if dfxk.dot(d_k.T) < 0: break
            n_k = n_k / 10
            d_start = d_k
            
            
        
        # alpha_k search by Line_search_tool
        alpha_k = line_search_tool.line_search(oracle, x_k, d_k)
        

        
        # Updating x_k
        x_k = x_k + alpha_k * d_k
        
    
    return x_k, 'iterations_exceeded', history
