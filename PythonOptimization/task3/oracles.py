import numpy as np
import scipy
from scipy.special import expit


def lasso_duality_gap(x, Ax_b, ATAx_b, b, regcoef):
    """
    Estimates f(x) - f* via duality gap for 
        f(x) := 0.5 * ||Ax - b||_2^2 + regcoef * ||x||_1.
    """
    # TODO: implement.
    
    
    temp = np.linalg.norm(ATAx_b, ord=np.inf)
    
    mu = Ax_b
    if temp != 0.0:
        mu = min(1.0, regcoef / temp) * Ax_b
    
    dualityGap = 0.5 * np.linalg.norm(Ax_b)**2 + regcoef * np.linalg.norm(x, ord=1) + \
           0.5 * np.linalg.norm(mu)**2 + b.dot(mu)
    
    return dualityGap
    
    
    #Even though it is not required to create a class LassoBarrierOracle, it seems like a logical thing to do in logicalcontinuation of previous tasks. Due to the lack of programming experience of nessesary kind, consultations with fellow course takers had to be made.
    
class LassoBarrierOracle():
    '''
    Oracle for barrier method solving LASSO
    f(x, u) =  1/2 * ||Ax - b||_2^2 + regcoef * sum_i u_i subject to  -u_i <= x_i <= u_i.
    f_t(x, u) = t * f(x, u) - sum_i( log(u_i + x_i) + log(u_i - x_i) )
    '''
    def __init__(self, A, b, regcoef):
        self.ATA = (A.T).dot(A)
        self.b = b
        self.regcoef = regcoef
        self.n = A.shape[1]
        self.matvec_Ax = lambda x: A.dot(x)
        self.matvec_ATx =  lambda x: (A.T).dot(x)
        self.matvec_Ax_b =  lambda x: A.dot(x) - b
        self.matmatvec_ATAx_b = lambda x: (A.T).dot(A.dot(x) - b)

    def func(self, x, u, t):
        #computes f_t(x, u)
        #Here and further f_t is actually divided by t. That is so to able to use cholesky (otherwise matrix is not positively difined). For this unobvious crutch thank to Shibaev Inokentiy. Using t^2 for example creates numbers to large
        m = self.b.shape[0]
        return  ( t * ( 0.5 * np.linalg.norm(self.matvec_Ax_b(x))**2 + self.regcoef * (np.ones(self.n)).dot(u)) - (np.sum(np.log(u - x)) + np.sum(np.log(u + x))) ) / t


    def grad(self, x, u, t):
        #computes gradient f_t: df_t(x, u) = (df_t / dx ; df_t / du)
        m = (self.b).shape[0]
        c1 = np.divide(np.ones(self.n), u - x)
        c2 = np.divide(np.ones(self.n), u + x)
        dft_x = (t * self.matmatvec_ATAx_b(x) + (c1 - c2) ) / t
        dft_u = (t * self.regcoef * np.ones(self.n) - c1 - c2 ) / t
        return np.concatenate((dft_x, dft_u), axis=0)


    def hess(self, x, u, t):
        #computes hessian f_t
        c1 = np.divide(np.ones(self.n), u - x)
        c2 = np.divide(np.ones(self.n), u + x)
        
        ft_xx = ( t * self.ATA + np.diag(c1 * c1 + c2 * c2) ) / t
        ft_xu = np.diag(- c1 * c1 + c2 * c2) / t
        ft_uu = np.diag(c1 * c1 + c2 * c2) / t
        ft_hess_uper = np.concatenate((ft_xx, ft_xu), axis=0)
        ft_hess_down = np.concatenate((ft_xu, ft_uu), axis=0)
        hess_ft = np.concatenate((ft_hess_uper, ft_hess_down), axis=1)
        return hess_ft

    def func_directional(self, x, u, t, d, alpha):
        #Computes phi(alpha) = f_t(x + alpha*d).
        pare = np.concatenate((x, u), axis=0)
        pare += alpha * d
        x_new, u_new = np.split(pare, 2)
        return np.squeeze(self.func(x_new, u_new, t))

    def grad_directional(self, x, u, t, d, alpha):
        #Computes phi'(alpha) = d(f_t(x + alpha*d)) / d(alpha)
        pare = np.concatenate((x, u), axis=0)
        pare += alpha * d
        x_new, u_new = np.split(pare, 2)
        return np.squeeze(self.grad(x_new, u_new, t).dot(d))
    
    
