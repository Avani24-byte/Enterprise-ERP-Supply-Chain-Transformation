import axiosInstance from "./axiosInstance";

export const getOrders = async () => {
  const response = await axiosInstance.get("/orders");
  return response.data;
};
