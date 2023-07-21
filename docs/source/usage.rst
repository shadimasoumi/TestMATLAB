Usage
=====

.. _Stokes Vector:

Stokes Vector
------------

Birefringence is measured using Stokes vectors ``S1`` and ``S2``, corresponding to the Stokes vectors measured 
for an input polarization state modulated between states orthogonal on the
:ref:`Poincaree Sphere`, using :ref:`Spectral binning`

.. code-block:: console

   function out = PSProcess(S1,S2,procStruct)

.. math:: S_p=\begin{bmatrix} I_p\\Q_p\\U_p\\V_p \end{bmatrix}

.. _Poincare Sphere:

Poincare Sphere
----------------

Test hyperlink: SO_.
    
.. _SO: https://www.thorlabs.com/newgrouppage9.cfm?objectgroup_id=14200

.. image:: docs/source/PoincareSphereIntro_A1-350.gif

.. _Spectral binning:

Spectral binning
----------------

The ``kind`` parameter should be either ``"meat"``, ``"fish"``,
or ``"veggies"``. Otherwise, :py:func:`lumache.get_random_ingredients`
will raise an exception.

.. autoexception:: lumache.InvalidKindError

For example:

>>> import lumache
>>> lumache.get_random_ingredients()
['shells', 'gorgonzola', 'parsley']

