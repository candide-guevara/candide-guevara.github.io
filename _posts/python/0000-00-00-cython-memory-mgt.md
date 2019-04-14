---
title: Python, Cython handling chunks of memory
date: 2018-02-28
categories: [cs_related, python]
---

In cython you have many ways of managing a chunk of memory.

* python bytes, bytearrays and memoryviews
* [raw pointers][3]
* cython [memoryviews][0] (different from python's), [array][1]
* [numpy arrays][2]

It is not always clear how you can transform one representation to another. 
Moreover it is difficult to remember if the transformation implies a copy.
Some transformations are not safe since a raw pointer to python memory can be invalidated.
For example, if it pointed to a bytearray that got relocated due to an increase in size.

![cython_mem_transforms]({{ site.images }}/Cython_Mem_Transforms.svg){: .my-inline-img }

## Example code

	from libc cimport string
	from cpython cimport buffer, array
	import array
	import numpy as np
	cimport numpy as np

	cdef extern from "Python.h":
			object PyMemoryView_FromMemory(char *mem, Py_ssize_t size, int flags)
			object PyMemoryView_FromBuffer(buffer.Py_buffer* view)

	# bytearray ==> memory_view (NO copy)
	# bytes cannot be transformed to memviews. unless cython >= 0.28 (with const memviews)
	cdef bytearray ba1 = bytearray(b'choco')
	cdef char[:] mv1 = ba1
	ba1[0] = b'z'
	print(ba1, <bytes>mv1[0], len(mv1))

	# bytearray/bytes ==> raw_ptr (NO copy unsafe)
	cdef char* rp2 = ba1
	cdef char* rp3 = b'choco'
	ba1[0] = b'v'
	print(<bytes>rp2[0], string.strlen(rp2), <bytes>rp3[0])

	# memory_view ==> raw_ptr (NO copy, unsafe if underlying python array is relocated)
	cdef char* rp1 = &mv1[0]
	mv1[0] = b'x'
	print(<bytes>rp1[0], string.strlen(rp1))

	# memory_view ==> bytes/bytearray (COPY)
	cdef object mv3 = memoryview(mv1) # cython slices are not real python memoryviews (NO copy)
	cdef bytes by3 = mv3.tobytes()
	mv1[0] = b't'
	print(by3, mv3.tobytes(), mv1, mv3)

	# raw_ptr ==> bytes/bytearray (COPY)
	cdef bytes by1 = rp1 # only works if null terminated
	cdef bytearray by2 = rp1[:5]
	rp1[0] = b'y'
	print(by1, by2)

	# raw_ptr ==> memory_view (NO copy)
	cdef object mv2 = PyMemoryView_FromMemory(rp1, 5, buffer.PyBUF_READ)
	rp1[0] = b'w'
	print(mv2.tobytes())
	# Does this work with cython >= 0.28 ?
	#cdef const char[:] mv2 = rp1[:5]

	#######################################################################

	# array ==> memory_view (NO copy)
	cdef array.array ar1 = array.array('i', [0,1,2,3])
	cdef int[:] mv1 = ar1
	ar1[0] = 111
	print(mv1[0], len(mv1), ar1.tobytes())

	# array ==> raw_ptr (NO copy unsafe)
	cdef int* rp1 = <int*>ar1.data.as_voidptr
	rp1[0] = 222
	print(rp1[0], ar1.data.as_ints[0])

	# memory_view ==> raw_ptr (NO copy unsafe)
	cdef int* rp2 = <int*>&mv1[0]
	mv1[0] = 333
	print(rp2[0], mv1[0])

	# memory_view ==> array (COPY)
	cdef array.array ar2 = array.array(mv1.base.typecode, mv1) # mv1.base is the python array
	ar2[0] = 444
	print(ar2.tolist(), mv1[0])

	# raw_ptr ==> memory_view (NO copy)
	cdef buffer.Py_buffer raw_buf
	cdef int flags = buffer.PyBUF_FORMAT | buffer.PyBUF_CONTIG
	buffer.PyBuffer_FillInfo(&raw_buf, <object>NULL, rp1, sizeof(int) * 4, 0, flags)
	raw_buf.itemsize = sizeof(int)
	raw_buf.format = b'i'
	raw_buf.ndim = 1
	cdef Py_ssize_t shape = 4
	raw_buf.shape = &shape
	cdef object mv2 = PyMemoryView_FromBuffer(&raw_buf)
	rp1[0] = 555
	print(mv2[0], mv2.tobytes())

	# raw_ptr ==> array (COPY)
	cdef array.array ar3 = array.array('i', [])
	array.extend_buffer(ar3, <char*>rp1, 4)
	rp1[0] = 666
	print(ar3.tolist())

	#######################################################################

	# python list/tuple <==> c array (COPY)
	cdef list pl1 = [1,2,3]
	cdef int[3] cl1 = pl1
	cl1[0] = 666
	cdef list pl2 = cl1
	print(cl1, pl1, pl2)

	# numpy array => memory_view (NO copy)
	cdef np.ndarray np1 = np.zeros([4], np.int)
	cdef long[:] mv1 = np1
	np1[0] = 111
	print(np1, mv1[0])

	## numpy array ==> raw ptr (NO copy)
	cdef long* rp1 = <long*>np.PyArray_DATA(np1)
	np1[0] = 222
	print(rp1[0], np1[0])

	# raw ptr ==> numpy array (broken)
	#cdef int shape = 4
	#cdef object np2 = np.PyArray_SimpleNewFromData(1, &shape, np.NPY_LONG, rp1)

[0]: http://docs.cython.org/en/latest/src/userguide/memoryviews.html#syntax
[1]: http://docs.cython.org/en/latest/src/tutorial/array.html#zero-overhead-unsafe-access-to-raw-c-pointer
[2]: http://docs.cython.org/en/latest/src/tutorial/numpy.html#adding-types
[3]: http://docs.cython.org/en/latest/src/tutorial/strings.html#passing-byte-strings

