# Author: Sungbeen Park
# Dec. 2021 --

import numpy as np

from matplotlib import cm

from nilearn import plotting as nplt
from nilearn.connectome import ConnectivityMeasure

import teneto
# from teneto import TemporalNetwork
# from teneto.utils import *

## =====================================================================================
class preprocessed:
    def __init__(self, tsmean, atlas=None):
        """
        Parameters
        ----------
        atlas: 3D Nifti1Image
            A brain parcellation atlas with specific mask labels for each parcellated region.
        
        tsmean: dict
            key 는 (subjID, run) 꼴의 tuple, value 는 (# time) x (# node) 인 행렬.
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
            self.nnodes = len(np.unique(self.atlas.get_fdata())[1:])
            self.nodecoord = self._grab_coord()
        self.tsmean = tsmean

    def get_temporal_corrmat_by_mapping(self, nwindows):
        """
        tsmean를 mapping(practice vs. unpractice)에 따라 분류한 후, window 수만큼 등분하여 각 window 내에서 node 간의 Pearson correlation 을 계산하여 행렬로 반환한다.
        
        Parameters
        -------
        nwindows: integer
            nwindows는 tsmean (# times x # nodes) 의 시간성분을 n등분해야 하므로, # times 의 약수여야 한다.
            
        Returns
        -------
        temporal Pearson correlation matrix by subject ID: dict
        
        Examples
        --------
            
        Notes
        -----

        """
        ## windowed_tsmean_by_mapping.shape = (# runs x # windows, A width of the window, # nodes) = (# subjects, # samples, # features)
        windowed_tsmean_by_mapping =  self._get_windowed_tsmean_by_mapping(nwindows)
        
        measure = ConnectivityMeasure(kind='correlation')
        temporal_corrmat = {}
        for k, v in windowed_tsmean_by_mapping.items():
            ## temporal_corrmat.shape = (A width of the window x # runs, # nodes, # nodes)
            temporal_corrmat[k] = measure.fit_transform(v)
            
        return temporal_corrmat
    
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
        >>> preproc = SamNet.preprocessing(atlas=tsmean['map'], tsmean=tsmean_genuine)
        >>> preproc._grab_coord()
        array([[-38.06505874, -18.98749404,   9.26162278],
               [-39.87492733,  -7.59181096,   8.21630641],
               [ 35.82923535, -17.49693844,   8.69334845],
               [ 36.92424392,  -6.78418091,   8.0817014 ], ...]])
               
        """
        return nplt.find_parcellation_cut_coords(labels_img=self.atlas)
    
    def _get_windowed_tsmean_by_mapping(self, nwindows):
        """
        시간에 따른 변화를 관찰하기 위해서, tsmean(RUN 당, 주어진 node의 평균 시계열)를 mapping(practice vs. unpractice)에 따라 분류한 후  time window 개수(nwindows)로 등분한다.
        그 후, 피험자 ID 별로 concatenate 한 tsmean 을 반환한다.
        
        Parameters
        -------
        nwindows: integer
            RUN 당 나눌 window 수. 
            여기서 nwindows는 tsmean (# times in a RUN x # nodes) 의 시간성분을 n등분해야 하므로, # times 의 약수여야 한다.
            
        Returns
        -------
        divided_tsmean: dict
            주어진 window 개수만큼 분할된 tsmean 를 subj ID 별로 반환.
            ex) >>> tsmean.shape
                (# times x # runs, 103)
                >>> windowed_tsmean = preproc._get_windowed_tsmean(nwindows)
                >>> windowed_tsmean.shape
                (# windows x # runs, a width of a window, # nodes)
        
        Examples
        --------
            
        Notes
        -----

        """
        ## ID(ggnn) 별로 RUN list 만들고, 빠진 RUN 표시
        tmp_s = []
        tmp_r = []
        presence_run = {}
        for ggnn, run in self.tsmean.keys():
            tmp_s.append(ggnn)
            tmp_r.append(run)
            if ggnn in presence_run.keys():
                presence_run[ggnn].append(run)
            else:
                presence_run[ggnn] = [run]
        list_ggnn = np.unique(tmp_s)
        list_run = np.unique(tmp_r)
        print("list_subj: %s"%list_ggnn)
        print("list_run: %s"%list_run)

        absence_run = {}
        for ggnn in list_ggnn:
            absence_run[ggnn] = []
            for run in list_run:
                if not run in presence_run[ggnn]:
                    absence_run[ggnn].append(run)
            if len(absence_run[ggnn])==0:
                del absence_run[ggnn]
        print("absence_run: %s"%absence_run)
        
        ## mapping(mm), subj(nn) 별로 run 수 세기. tsmean을 mmnn 별로 reshape 할 때 필요함.
        mmnn = {}
        for s in list_ggnn:
            gg, nn = s[:2], s[2:]
            for mm in ['practice', 'unpractice']:
                key = mm+'_'+nn
                mmnn[key] = 0
        for s, r in self.tsmean.keys():
            mm = 'practice' if r in ['r01','r02','r03'] else ('unpractice' if r in ['r04','r05','r06'] else 'invalid')
            gg, nn = s[:2], s[2:]
            key = mm+'_'+nn
            mmnn[key] += 1
#         print("subj, mapping 별 RUN 수: %s"%mmnn)
                    
        ## RUN 순서에 맞게 정렬한 후 tsmean 을 각 subj mapping 별로 concatenate
        tsmean_concat = {}
        for (ID, run), value in sorted(self.tsmean.items()):
            ## value.shape = (# times, # nodes)
            gg, nn = ID[:2], ID[2:]
            mm = 'practice' if run in ['r01','r02','r03'] else ('unpractice' if run in ['r04','r05','r06'] else 'invalid')
            key = mm+'_'+nn
            if key in tsmean_concat.keys():
                ## axis=0: time, axis=1: node
                tsmean_concat[key] = np.concatenate([tsmean_concat[key], value], axis=0)
            else:
                tsmean_concat[key] = value
        
        ## tsmean_windowed.shape = (# runs x # windows, A width of the window, # nodes)
        tsmean_windowed = {}
        for key, value in tsmean_concat.items():
            tsmean_windowed[key] = value.reshape(mmnn[key]*nwindows, -1, self.nnodes)
            
        return tsmean_windowed
    
    def plot_connectom(self, adjacency_matrix=None, node_coords=None, edge_threshold=None, colorbar=False):
        """
        connectom 을 그린다

        Parameters
        -------
        adjacency_matrix: numpy array of shape (n, n)
            Represents the link strengths of the graph. The matrix can be symmetric which will result in an undirected graph, or not symmetric which will result in a directed graph.
            
        edge_threshold: str or number, optional
            If it is a number only the edges with a value greater than edge_threshold will be shown. If it is a string it must finish with a percent sign, e.g. “25.3%”, and only the edges with a abs(value) above the given percentile will be shown.

        Notes
        -----

        Examples
        --------
        >>> from utils_Park import network as SamNet
        >>> preproc = SamNet.preprocessing(atlas=tsmean['map'], tsmean=tsmean_genuine)
        >>> preproc.plot_node()
        ...
               
        """
        gradient = np.linspace(0,1,self.nnodes)
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
            The colormap to use. Either a string which is a name of a matplotlib colormap, or a matplotlib colormap object. Default=`plt.cm.gist_ncar`.
            
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
## =====================================================================================
class temporalnetwork():
    def __init__(self, temporal_corrmat, nettype='wu'
            , timetype=None, timeunit=None, desc=None, starttime=None, timelabels=None
            , diagonal=False, nodelabels=None
            , forcesparse=False, dense_threshold=0.25):
        """
        A class for temporal networks.
        This class allows to call different teneto functions within the class and store the network representation

        Parameters
        ----------
        temporal_corrmat: ndarray
            (# nodes, # nodes, # layers) temporal correlation matrix
        nettype: str
            description of network. Can be: bu, bd, wu, wd where the letters stand for binary, weighted, undirected and directed. Default is weighted and undirected.

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
            When forsesparse if False (default), if importing array and if dense_threshold% (default%) edges are present, tnet.network is an array. If forsesparse is True, then this inhibts arrays being created.
            
        dense_threshold: float
            If forsesparse == False, what percentage (as a decimal) of edges need to be present
            in order for representation to be dense.

        Notes
        -----
        temporal_corrmat 는 dict 형식이 아님에 유의한다.

        """
        self.tnet = teneto.TemporalNetwork(
            from_array=temporal_corrmat, nettype=nettype
            , timetype=timetype, timeunit=timeunit, desc=desc, starttime=starttime, timelabels=timelabels
            , diagonal=diagonal, nodelabels=nodelabels
            , forcesparse=forcesparse, dense_threshold=dense_threshold
        )
        print(self.tnet.netshape)
        
    def get_network_when(self, i=None, j=None, t=None, ij=None, logic='and', copy=False, asarray=False, netshape=None, nettype=None):
        """
        Returns subset of dataframe that matches index
        
        Parameters
        ----------
        tnet: df, array or teneto.TemporalNetwork
            teneto.TemporalNetwork object or pandas dataframe edgelist
        i: list or int
            get nodes in column i (source nodes in directed networks)
        j: list or int
            get nodes in column j (target nodes in directed networks)
        t: list or int
            get edges at this time-points.
        ij: list or int
            get nodes for column i or j (logic and can still persist for t). Cannot be specified along with i or j
        logic: str
            options: ‘and’ or ‘or’. If ‘and’, functions returns rows that corrspond that match all i,j,t arguments. If ‘or’, only has to match one of them
        copy: bool
            default False. If True, returns a copy of the dataframe. Note relevant if hd5 data.
        asarray: bool
            default False. If True, returns the list of edges as a numpy array.
            
        Returns
        -------
        df: pandas dataframe
            Unless asarray are set to true.

        """
        df = teneto.utils.get_network_when(
            tnet=self.tnet
            , i=i, j=j, t=t, ij=ij, logic=logic, copy=copy
            , asarray=asarray, netshape=netshape, nettype=nettype
        )
        return df
    
    def create_supraadjacency_matrix(self, omega=1):
        """
        Returns a supraadjacency matrix from a temporal network structure
        
        Parameters
        ----------
        omega: int
            Interslice weight of multilayer clustering ($\omega$) that links the same node from adjacent time-points. Must be positive. The default is equal to 1.           
        
        Returns
        -------
        supranet: dataframe
            Supraadjacency matrix

        """
        supranet = teneto.utils.create_supraadjacency_matrix(
            tnet=self.tnet
            , intersliceweight=omega
        )
        return supranet
    
    def create_networkx_supra(self, omega=1):
        """
        Creates undirected networkx object
        
        Parameters
        ----------
        omega: int
            Interslice weight of multilayer clustering ($\omega$) that links the same node from adjacent time-points. Must be positive. The default is equal to 1.
            
        Returns
        -------
        nxsupra: networkx object
            supraadjacency matrix converted to networkx form
            
        Notes
        -----
        df: pandas dataframe
            Supraadjacency matrix
        weight 가 0 이하이면, 연결이 없는 edge 로 본다.
        
        """
        supranet = self.create_supraadjacency_matrix(omega=omega)
        supranet = supranet[supranet['weight']>0]
        nxsupra = teneto.utils.tnet_to_nx(df=supranet)

        return nxsupra
        
## =====================================================================================
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