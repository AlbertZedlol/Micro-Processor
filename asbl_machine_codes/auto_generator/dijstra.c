#include <stdio.h>
#pragma warning(disable:4996)
#define _CRT_SECURE_NO_WARNINGS


int buffer[1025], dist[32], visited[32];

void dijkstra(int n, int * graph);
    
int main()
{
    FILE * f;
    int n;

    // Input
    f = fopen("./test.dat", "rb");
    fread(buffer, sizeof(buffer), 1, f);
    fclose(f);
    n = buffer[0];//size of the array, which is 6 in our case.
    int * graph = (int *)(buffer + 1);//star of the data arrays.

    // Dijkstra
    dijkstra(n, graph);

    // Output
    for (int i = 1; i < n; i++)
    {
        printf("%d ", dist[i]);
    }

    int sum = 0;
    for (int i = 1; i < n; i++)
    {
        sum += dist[i];
    }
    print("\n>>>Sum of the minimum distances==%d\n", sum);

    return 0;
}

void dijkstra(int n, int * graph)
{
    // Initialization
    dist[0] = 0;
    visited[0] = 1;
    for (int i = 1; i < n; i++)
    {
        dist[i] = graph[i];
        visited[i] = 0;
    }

    // Greedy search
    for (int i = 1; i < n; i++)
    {
        // Search for nearest unvisited node
        int u = -1, min_dist = -1;
        for (int v = 1; v < n; v++)
        {
            if (visited[v] != 0 || dist[v] == -1) continue;
            if (min_dist == -1 || dist[v] < min_dist)
            {
                min_dist = dist[v];
                u = v;
            }
        }
        if (min_dist == -1) return;

        // Update
        visited[u] = 1;
        for (int v = 1; v < n; v++)
        {
            if (visited[v] != 0) continue;
            int addr = (u << 5) + v;
            if (graph[addr] == -1) continue;
            if (dist[v] == -1 || dist[v] > min_dist + graph[addr])
            {
                dist[v] = min_dist + graph[addr];
            }
        }
    }
}