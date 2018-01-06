import numpy as np
import scipy
from scipy.special import expit
from scipy import sparse

class BaseSmoothOracle(object):
    """
    Base class for implementation of oracles.
    """

    def func(self, x):
        """
        Computes the value of function at point x.
        """
        raise NotImplementedError('Func oracle is not implemented.')

    def grad(self, x):
        """
        Computes the gradient at point x.
        """
        raise NotImplementedError('Grad oracle is not implemented.')

    def hess(self, x):
        """
        Computes the Hessian matrix at point x.
        """
        raise NotImplementedError('Hessian oracle is not implemented.')

    def func_directional(self, x, d, alpha):
        """
        Computes phi(alpha) = f(x + alpha*d).
        """
        return np.squeeze(self.func(x + alpha * d))

    def grad_directional(self, x, d, alpha):
        """
        Computes phi'(alpha) = (f(x + alpha*d))'_{alpha}
        """
        return np.squeeze(self.grad(x + alpha * d).dot(d))

    def hess_vec(self, x, v):#							hess_vec
        """
        Computes matrix-vector product with Hessian matrix f''(x) v
        """
        return self.hess(x).dot(v)


class QuadraticOracle(BaseSmoothOracle):
    """
    Oracle for quadratic function:
       func(x) = 1/2 x^TAx - b^Tx.
    """

    def __init__(self, A, b):
        if not scipy.sparse.isspmatrix_dia(A) and not np.allclose(A, A.T):
            raise ValueError('A should be a symmetric matrix.')
        self.A = A
        self.b = b

    def func(self, x):
        return 0.5 * np.dot(self.A.dot(x), x) - self.b.dot(x)

    def grad(self, x):
        return self.A.dot(x) - self.b

    def hess(self, x):
        return self.A

    def minimize_directional(self, x, d):
        """
        Minimizes the function with respect to a specific direction:
            Finds alpha = argmin f(x + alpha d)
        """
        # TODO: Implement for bonus part					BONUS
        pass


class LogRegL2Oracle(BaseSmoothOracle):
    """
    Oracle for logistic regression with l2 regularization:
         func(x) = 1/m sum_i log(1 + exp(-b_i * a_i^T x)) + regcoef / 2 ||x||_2^2.

    Let A and b be parameters of the logistic regression (feature matrix
    and labels vector respectively).
    For user-friendly interface use create_log_reg_oracle()

    Parameters
    ----------
        matvec_Ax : function
            Computes matrix-vector product Ax, where x is a vector of size n.
        matvec_ATy : function of y
            Computes matrix-vector product A^Ty, where y is a vector of size m.
        matmat_ATsA : function
            Computes matrix-matrix-matrix product A^T * Diag(s) * A,
    """

    def __init__(self, matvec_Ax, matvec_ATx, matmat_ATsA, matmat_ATsAv, b, regcoef):
        self.matvec_Ax = matvec_Ax
        self.matvec_ATx = matvec_ATx
        self.matmat_ATsA = matmat_ATsA
        self.matmat_ATsAv = matmat_ATsAv
        self.b = b
        self.regcoef = regcoef
        
    def func(self, x):
        # Done (subject to check)
        m = self.b.shape[0]
        return (1 / m ) * np.logaddexp(0, -self.b * self.matvec_Ax(x)).sum() + 1/2*self.regcoef * x.T.dot(x)
        #return (1/m) * (np.log(np.ones(m) + np.exp(-self.b * self.matvec_Ax(x)))).dot(np.ones(m)) + self.regcoef / 2 * x.T.dot(x)

    def grad(self, x):
        #Done (subject to check)
        m = self.b.size
        arg = self.b * self.matvec_Ax(x)
        return (-1/m) * self.matvec_ATx(self.b * scipy.special.expit(- arg)) + self.regcoef * x

    def hess(self, x):
        # Done (subject to check)
        m = self.b.size
        arg = self.b * self.matvec_Ax(x)
        toBeDiag = self.b * self.b * scipy.special.expit(- arg) * scipy.special.expit(arg)
        return (1/m) * self.matmat_ATsA(toBeDiag) + self.regcoef * np.eye(x.size)
    
    def hess_vec(self, x, v):
        m = self.b.size
        arg = self.b * self.matvec_Ax(x)
        toBeDiag = self.b * self.b * scipy.special.expit(- arg) * scipy.special.expit(arg)
        return (1/m) * self.matmat_ATsAv(toBeDiag, v) + self.regcoef * v
        


class LogRegL2OptimizedOracle(LogRegL2Oracle):
    """
    Oracle for logistic regression with l2 regularization
    with optimized *_directional methods (are used in line_search).

    For explanation see LogRegL2Oracle.
    """

    def __init__(self, matvec_Ax, matvec_ATx, matmat_ATsA, matmat_ATsAv, b, regcoef):
        super().__init__(matvec_Ax, matvec_ATx, matmat_ATsA, b, regcoef)

    def func_directional(self, x, d, alpha):
        # TODO: Implement optimized version with pre-computation of Ax and Ad	Bonus
        return None

    def grad_directional(self, x, d, alpha):
        # TODO: Implement optimized version with pre-computation of Ax and Ad	Bonus
        return None


def create_log_reg_oracle(A, b, regcoef, oracle_type='usual'):
    """
    Auxiliary function for creating logistic regression oracles.
        `oracle_type` must be either 'usual' or 'optimized'
    """
    matvec_Ax = lambda x: A.dot(x) # Done
    matvec_ATx = lambda x: (A.T).dot(x) # Done

    def matmat_ATsA(s):
        # Done
        if sparse.isspmatrix(A):
            return A.T.dot(sparse.diags(s).dot(A))
        else:
            return A.T.dot(np.diag(s).dot(A))
        
    def matmat_ATsAv(s, v):
        if sparse.isspmatrix(A):
            return (A.T).dot((sparse.diags(s)).dot(A.dot(v)))
        else:
            return (A.T).dot((np.diag(s)).dot(A.dot(v)))
    
    if oracle_type == 'usual':
        oracle = LogRegL2Oracle
    elif oracle_type == 'optimized':
        oracle = LogRegL2OptimizedOracle
    else:
        raise 'Unknown oracle_type=%s' % oracle_type
    return oracle(matvec_Ax, matvec_ATx, matmat_ATsA, matmat_ATsAv, b, regcoef)


def hess_vec_finite_diff(func, x, v, eps=1e-5):
    """
    Returns approximation of the matrix product 'Hessian times vector'
    using finite differences.
    """
    # TODO: Implement numerical estimation of the Hessian times vector		Task2
    n = x.size
    e = np.eye(n)
    result = np.zeros(n)
    
    for i in range(0, n):
        result[i] = (func(x + eps * e[i] + eps * v) - func(x + eps * e[i]) - func(x + eps * v) + func(x)) / eps ** 2
        
    return result
