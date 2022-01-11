# Author: Sungbeen Park
# Dec. 2021 --

import numpy as np

from matplotlib import cm

from nilearn import plotting as nplt
from nilearn.connectome import ConnectivityMeasure

import teneto
# from teneto import TemporalNetwork
# from teneto.utils import *

class preprocessed:
    def __init__(self, tsmean, atlas=None, nodelabels=None):
        """
        Parameters
        ----------
        atlas: 3D Nifti1Image
            A brain parcellation atlas with specific mask labels for each parcellated region.

        nodelables: list
        
        tsmean: dict
            key 는 (subjID, run) 꼴의 tuple, value 는 (# time) X (# node) 인 행렬.
            ex) tsmean[('GA01','r02')]
            >>> array([[-0.41779792, -0.495137  , -0.57128936, ..., -0.17376667,
                        -0.0662156 , -0.05547401],
                       [-0.39420527, -0.49601927, -0.5378227 , ..., -0.17531115,
                        -0.07193347, -0.07622985], 
                        ...
                       [-0.43382448, -0.45101503, -0.59778893, ..., -0.1706062 ,
                        -0.05122897, -0.03065274],
                       [-0.4316919 , -0.48008043, -0.59211165, ..., -0.17244516,
                        -0.05938045, -0.04040354]], dtype=float32)

        """
        if atlas is not None:
            self.atlas = atlas
            self.nodecoord = self._grab_coord()
        if nodelabels is not None:
            self.nodelabels = nodelabels
        self.tsmean = tsmean
    
    def _grab_coord(self):
        """
        altas 상의 각 노드들의 center of mass 의 3D 좌표를 구해준다.
        
        Returns
        -------
        coords: numpy.ndarray of shape (n_labels, 3)
            Label regions cut coordinates in image space (mm)

        Notes
        -----

        Examples
        --------
        >>> from utils_Park import network as SamNet
        >>> preproc = SamNet.preprocessing(atlas=tsmean['map'], nodelabels=tsmean['labels'], tsmean=tsmean_genuine)
        >>> preproc._grab_coord()
        array([[-38.06505874, -18.98749404,   9.26162278],
               [-39.87492733,  -7.59181096,   8.21630641],
               [ 35.82923535, -17.49693844,   8.69334845],
               [ 36.92424392,  -6.78418091,   8.0817014 ], ...]])
               
        """
        return nplt.find_parcellation_cut_coords(labels_img=self.atlas)
    
    def _get_windowed_tsmean(self, nwindows):
        """
        시간에 따른 변화를 관찰하기 위해서, tsmean(RUN 당, 주어진 node의 평균 시계열)을 time window 개수(nwindows)로 등분한다.
        그 후, 피험자 ID 별로 concatenate 한 tsmean 을 반환한다.
        
        Parameters
        -------
        nwindows: integer
            RUN 당 나눌 window 수. 
            여기서 nwindows는 tsmean (# times in a RUN X # nodes) 의 시간성분을 n등분해야 하므로, # times 의 약수여야 한다.
            
        Returns
        -------
        divided_tsmean: dict
            주어진 window 개수만큼 분할된 tsmean 를 subj ID 별로 반환.
            ex) >>> tsmean.shape
                (# times X # runs, 103)
                >>> windowed_tsmean = preproc._get_windowed_tsmean(nwindows)
                >>> windowed_tsmean.shape
                (# windows X # runs, a width of a window, # nodes)
        
        Examples
        --------
            
        Notes
        -----

        """
        ## subj ID, run list 만들기
        tmp_s = []
        tmp_r = []
        for s, r in self.tsmean.keys():
            tmp_s.append(s)
            tmp_r.append(r)
        list_subj = np.unique(tmp_s)
        list_run = np.unique(tmp_r)
        print("list_subj: %s"%list_subj)
        print("list_run: %s"%list_run)
        
        ## subj ID 별로 run 수 세기
        tmp = {}
        for s in list_subj:
            tmp[s] = 0
        for s, r in self.tsmean.keys():
            tmp[s] += 1
        cnt = np.zeros(len(list_subj)).astype(int)
        for i, (s, v) in enumerate(tmp.items()):
            cnt[i] = v
        print("subj ID 별 RUN 수: %s"%cnt)
        
        ## RUN 순서에 맞게 정렬한 후 tsmean 을 각 subj ID 별로 concatenate
        tmp = {}
        for (subj, run), value in sorted(self.tsmean.items()):
            ## tsmean.shape = (# time points, # nodes)
            if subj in tmp.keys():
                ## concatenate windows
                tmp[subj] = np.concatenate([tmp[subj], value], axis=0)
            else:
                tmp[subj] = value
                ntimepoints, nnodes = value.shape
        
        ## windowed_tsmean.shape = (# windows, a width of a window, # nodes)
        windowed_tsmean = {}
        for i, subj in enumerate(list_subj):
            windowed_tsmean[subj] = tmp[subj].reshape(cnt[i]*nwindows, -1, nnodes)
        return windowed_tsmean

    def get_temporal_corrmat(self, nwindows):
        """
        tsmean를 window 수만큼 등분하여, 각 window 내에서 node 간의 Pearson correlation 을 계산하여 행렬로 반환한다.
        
        Parameters
        -------
        nwindows: integer
            nwindows는 tsmean (# times X # nodes) 의 시간성분을 n등분해야 하므로, # times 의 약수여야 한다.
            
        Returns
        -------
        temporal Pearson correlation matrix by subject ID: dict
        
        Examples
        --------
            
        Notes
        -----

        """
        windowed_tsmean =  self._get_windowed_tsmean(nwindows)
        
        measure = ConnectivityMeasure(kind='correlation')
        temporal_corrmat = {}
        for k, v in windowed_tsmean.items():
            ## temporal_corrmat.shape = (# nodes, # nodes, size of a window X runs)
            temporal_corrmat[k] = measure.fit_transform(v).T
            
        return temporal_corrmat
    
    def plot_connectom(self, adjacency_matrix=None, node_coords=None, edge_threshold=None, colorbar=False):
        """
        connectom 을 그린다

        Parameters
        -------
        adjacency_matrix: numpy array of shape (n, n)
            Represents the link strengths of the graph. The matrix can be symmetric which will result
            in an undirected graph, or not symmetric which will result in a directed graph.
            
        edge_threshold: str or number, optional
            If it is a number only the edges with a value greater than edge_threshold will be shown. 
            If it is a string it must finish with a percent sign, e.g. “25.3%”, and only the edges
            with a abs(value) above the given percentile will be shown.

        Notes
        -----

        Examples
        --------
        >>> from utils_Park import network as SamNet
        >>> preproc = SamNet.preprocessing(atlas=tsmean['map'], nodelabels=tsmean['labels'], tsmean=tsmean_genuine)
        >>> preproc.plot_node()
        ...
               
        """
        gradient = np.linspace(0,1,len(self.nodelabels))
        if adjacency_matrix is None:
            adjacency_matrix = np.zeros([len(gradient),len(gradient)])
            node_coords = self.nodecoord
 
        cmap = cm.get_cmap('gist_ncar')
        ## Separately plot the coordinates of centers with their own color.
        nplt.plot_connectome(
            adjacency_matrix=adjacency_matrix, node_coords=node_coords
            , node_color=cmap(gradient)
            , edge_threshold=edge_threshold
            , colorbar=colorbar
        )
    
    def plot_atlas(self, cmap='gist_ncar', colorbar=True, title=None):
        """
        atlas 를 그려준다.
        
        Parameters
        -------
        cmap: matplotlib.colors.Colormap, or str, optional
            The colormap to use. Either a string which is a name of a matplotlib colormap, or a matplotlib colormap object.
            Default=`plt.cm.gist_ncar`.
            
        colorbar: bool, optional
            If True, display a colorbar on the right of the plots. Default=True.
            
        title: str, or None, optional
            The title displayed on the figure. Default=None.

        Notes
        -----

        Examples
        --------
        >>> from utils_Park import network as SamNet
        >>> preproc = SamNet.preprocessing(atlas=tsmean['map'], nodelabels=tsmean['labels'], tsmean=tsmean_genuine)
        >>> preproc.plot_atlas()
        ...
               
        """
        print(np.unique(self.atlas.get_fdata()))
        nplt.plot_roi(roi_img=self.atlas, colorbar=colorbar, cmap=cmap, title=title)

class temporalnetwork():
    def __init__(self, temporal_corrmat, nettype='wu'
            , timetype=None, timeunit=None, desc=None, starttime=None, timelabels=None
            , diagonal=False, nodelabels=None
            , forcesparse=False, dense_threshold=0.25):
        """
        Parameters
        ----------
        nettype: str
            description of network. Can be: bu, bd, wu, wd where the letters stand for binary,
            weighted, undirected and directed. Default is weighted and undirected.

        from_array: array
            input data from an array with dimesnions (node, node, time)

        timetype: str
            discrete or continuous

        diagonal: bool
            if the diagonal should be included in the edge list.

        timeunit: str
            string (used in plots)

        desc: str
            string to describe network.

        startime: int
            integer represents time of first index.

        nodelabels: list
            list of labels for naming the nodes

        timelabels: list
            list of labels for time-points

        forcesparse: bool
            When forsesparse if False (default), if importing array and if dense_threshold% (default%)
            edges are present, tnet.network is an array. If forsesparse is True, then this inhibts arrays being created.
            
        dense_threshold: float
            If forsesparse == False, what percentage (as a decimal) of edges need to be present
            in order for representation to be dense.

        """
        self.tnet = teneto.TemporalNetwork(
            from_array=temporal_corrmat, nettype=nettype
            , timetype=timetype, timeunit=timeunit, desc=desc, starttime=starttime, timelabels=timelabels
            , diagonal=diagonal, nodelabels=nodelabels
            , forcesparse=forcesparse, dense_threshold=dense_threshold
        )
        print(self.tnet.netshape)
        
        
    def get_network_when(self, t):
        return teneto.utils.get_network_when(self.tnet, t=t)
#     def get_community(self, niter=1)

# class Module(Inheritance):
#     def __init__(self, addtional_parameters):
#         super().__init__()
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