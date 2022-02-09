# Author: Sungbeen Park
# Dec. 2021 --

import numpy as np
import pandas as pd

import matplotlib.pyplot as plt
from nilearn import plotting as nplt

def get_primfac(n):
    """
    Prime factorization with 'O(sqrt(n))' complexity (worst case). You can easily improve it by special-casing 2
    and looping only over odd 'd' (or special-casing more small primes and looping over fewer possible divisors)
    
    Parameters
    ----------
    n : int
    
    Returns
    -------
    primfac : array_like
        A list of factors
        
    Examples
    --------
    >>> primes(12)
    
    >>> array([2, 2, 3])
    """
    primfac = []
    d = 2
    while d*d <= n:
        while (n % d) == 0:
            primfac.append(d)  # supposing you want multiple factors repeated
            n //= d
        d += 1
    if n > 1:
        primfac.append(n)
    return np.array(primfac)

def get_fac(n):
    fac = []
    for i in range(1,n+1):
        if n % i == 0:
            fac.append(i)
    return np.array(fac)

def plot_correlation_matrix(correl_mat, vr=[-1,1], figsize=(15, 12), labels=None, cmap='jet', tri='lower', crect=[-0.05, .15, .02, .7]):
    """
    Correlation Matrix 를 plot 해줌
    
    Parameters
    ----------
    correl_mat : ndarray
        A three-dimensional correlation matrix composed of (layer, node, node)
    vr : array_like 
        A value(coefficient) range, i.e., [vmin, vmax]. The default is [-1, 1].
    figsize : (float, float)
        Width, height of each matrix in inches. The default is rcParams["figure.figsize"]=[15, 12]
    labels : list, ndarray of strings, empty list, False, or None, optional
        The label of each row and column. Needs to be the same length as rows/columns of mat.
        If False, None, or an empty list, no labels are plotted.
    cmap : matplotlib.colors.Colormap, or str, optional
        The colormap to use. Either a string which is a name of a matplotlib colormap, or a matplotlib colormap object.
        Default='jet'.
    tri : {‘full’, ‘lower’, ‘diag’}, optional
        Which triangular part of the matrix to plot: ‘lower’ is the lower part, ‘diag’ is the lower including diagonal,
        and ‘full’ is the full matrix. Default=’lower’.
    crect : sequence of float
        The dimensions [left, bottom, width, height] of the new Axes. 
        All quantities are in fractions of figure width and height.

    Returns
    -------

    Notes
    -----

    Examples
    --------

    >>>
    >>>
    >>>
    """
    nlayer, nnode, _ = correl_mat.shape
    
    ncol = np.min([4, nlayer])
    nrow = np.ceil(nlayer/4.).astype(int)
    
#     tmp = get_fac(nlayer)
#     ncol = tmp[(1<tmp)&(tmp<8)].max()
#     nrow = nlayer//ncol
    
    fig = plt.figure(figsize=(ncol*15, nrow*12), constrained_layout=True)

    gs = fig.add_gridspec(nrows=nrow, ncols=ncol)

    axs = []
    for i in range(nlayer):
        axs.append(fig.add_subplot(gs[i//ncol, i%ncol]))

    vmin, vmax = vr
    for i, layer in enumerate(range(nlayer)): ## early_practice windows + late_practice windows
        img = nplt.plot_matrix(correl_mat[layer,:,:]
                               , labels=labels, reorder=False
                               , vmax=vmax, vmin=vmin
                               , cmap=cmap
                               , tri=tri
                               , colorbar=False
                               , title='layer%02d'%(layer+1)
                               , axes=axs[i]
                              )
    cax = fig.add_axes(crect)
    cbar = fig.colorbar(img, cax=cax)
    cbar.ax.tick_params(labelsize=40)

    fig.tight_layout()
    
    """
    
    Parameters
    ----------

    Returns
    -------

    Notes
    -----

    Examples
    --------

    >>>
    >>>
    >>>
    """