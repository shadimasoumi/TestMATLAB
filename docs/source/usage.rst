Usage
=====

.. _Stokes Vector:

Stokes Vector
------------

Birefringence is measured using Stokes vectors ``S1`` and ``S2``, corresponding to the Stokes vectors measured 
for an input polarization state modulated between states orthogonal on the
:ref:`Poincaree Sphere`, using :ref:`Spectral binning`

.. code-block:: function out = PSProcess(S1,S2,procStruct)



.. math:: \begin{bmatrix} I\\Q\\U\\V \end{bmatrix}

.. _Poincare Sphere:

Poincare Sphere
----------------

To retrieve a list of random ingredients,
you can use the ``lumache.get_random_ingredients()`` function:

.. autofunction:: lumache.get_random_ingredients



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

