import { useState } from 'react';
import axiosInstance from '../api/axiosInstance';

export const useBoomnowSearch = () => {
  const [results, setResults] = useState(null);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  const search = async (city, adults) => {
    setLoading(true);
    setError(null);
    setResults(null);

    try {
      const response = await axiosInstance.post('/api/searches', {
        city,
        adults
      });
      setResults(response.data);
      setLoading(false);
      return response.data;
    } catch (err) {
      console.error('Error searching:', err);
      const errorMessage = err.response?.data?.errors || 
                          err.response?.data?.error || 
                          err.message || 
                          'An error occurred';
      const formattedError = Array.isArray(errorMessage) 
        ? errorMessage.join(', ') 
        : errorMessage;
      setError(formattedError);
      setLoading(false);
      throw err;
    }
  };

  const reset = () => {
    setResults(null);
    setError(null);
    setLoading(false);
  };

  return {
    search,
    results,
    error,
    loading,
    reset
  };
};

