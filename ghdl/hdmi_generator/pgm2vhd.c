#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define BUFFER_LENGTH 1024



int main (int argc, char ** argv)
{
    if (argc != 3)
    {
        printf("Error: wrong number of arguments\n");
        printf("\tusage: %s <infile> <outfile>\n", argv[0]);

        exit(EXIT_FAILURE);
    }

    char * infile_name = argv[1];
    char * outfile_name = argv[2];

    FILE * infile_fd = fopen(infile_name, "r");
    if (infile_fd == NULL)
    {
        printf("Error opening %s\n", infile_name);
        exit(EXIT_FAILURE);
    }

    FILE * outfile_fd = fopen(outfile_name, "w");
    if (outfile_fd == NULL)
    {
        printf("Error opening %s\n", outfile_name);
        exit(EXIT_FAILURE);
    }

    char magic[10];
    size_t len;

/* Get Header magic number (P5) */
    fscanf(infile_fd, "%s", magic);
    
    if (strncmp(magic, "P5", 2))
    {
        printf("Error: Format %s, expected P5\n", magic);
        exit(EXIT_FAILURE);
    }

/* Get dimensions */
    int h_res, v_res;

    fscanf(infile_fd, "%d %d", &h_res, &v_res);
    printf("%d %d\n", h_res, v_res);


/* Get max color */
    int max_color;

    fscanf(infile_fd, "%d", &max_color);
    printf("%d\n", max_color);

    if (max_color != 255)
    {
        printf("Max color != 255, I can't handle that :S\n");
    }

/* Dummy fread */
    uint8_t truc;
    fread(&truc, sizeof(uint8_t), 1, infile_fd);

/* Pixels, yay */
    int mod = 15;
    fprintf(outfile_fd, "library ieee;\n");
    fprintf(outfile_fd, "use ieee.std_logic_1164.all;\n");
    fprintf(outfile_fd, "\n");
    fprintf(outfile_fd, "entity dpram is\n");
    fprintf(outfile_fd, "    generic\n");
    fprintf(outfile_fd, "    (\n");
    fprintf(outfile_fd, "        mem_size    : natural := 720 * 480;\n");
    fprintf(outfile_fd, "        data_width  : natural := 8\n");
    fprintf(outfile_fd, "    );\n");
    fprintf(outfile_fd, "   port \n");
    fprintf(outfile_fd, "   (   \n");
    fprintf(outfile_fd, "        i_clk_a        : in std_logic;\n");
    fprintf(outfile_fd, "        i_clk_b        : in std_logic;\n");
    fprintf(outfile_fd, "\n");
    fprintf(outfile_fd, "       i_data_a    : in std_logic_vector(data_width-1 downto 0);\n");
    fprintf(outfile_fd, "       i_data_b    : in std_logic_vector(data_width-1 downto 0);\n");
    fprintf(outfile_fd, "       i_addr_a    : in natural range 0 to mem_size-1;\n");
    fprintf(outfile_fd, "       i_addr_b    : in natural range 0 to mem_size-1;\n");
    fprintf(outfile_fd, "       i_we_a      : in std_logic := '1';\n");
    fprintf(outfile_fd, "       i_we_b      : in std_logic := '1';\n");
    fprintf(outfile_fd, "       o_q_a       : out std_logic_vector(data_width-1 downto 0);\n");
    fprintf(outfile_fd, "       o_q_b       : out std_logic_vector(data_width-1 downto 0)\n");
    fprintf(outfile_fd, "   );\n");
    fprintf(outfile_fd, "   \n");
    fprintf(outfile_fd, "end dpram;\n");
    fprintf(outfile_fd, "\n");
    fprintf(outfile_fd, "architecture rtl of dpram is\n");
    fprintf(outfile_fd, "    -- Build a 2-D array type for the RAM\n");
    fprintf(outfile_fd, "    subtype word_t is std_logic_vector(data_width-1 downto 0);\n");
    fprintf(outfile_fd, "    type memory_t is array(0 to mem_size-1) of word_t;\n");
    fprintf(outfile_fd, "    \n");
    fprintf(outfile_fd, "    -- Declare the RAM\n");
    fprintf(outfile_fd, "    shared variable ram : memory_t := (\n");
    fprintf(outfile_fd, "        ");

    for (int i = 0 ; i < h_res * v_res-1 ; i++)
    {
        fread(&truc, sizeof(uint8_t), 1, infile_fd);
        fprintf(outfile_fd, "x\"%02x\", ", truc);
        if ((i % mod) == mod-1)
        {
            fprintf(outfile_fd, "\n        ");        
        }
    }

    fread(&truc, sizeof(uint8_t), 1, infile_fd);
    fprintf(outfile_fd, "x\"%02x\"\n", truc);
    fprintf(outfile_fd, "    );\n");

    fprintf(outfile_fd, "begin\n");
    fprintf(outfile_fd, "    -- Port A\n");
    fprintf(outfile_fd, "    process(i_clk_a)\n");
    fprintf(outfile_fd, "    begin\n");
    fprintf(outfile_fd, "        if(rising_edge(i_clk_a)) then \n");
    fprintf(outfile_fd, "            if(i_we_a = '1') then\n");
    fprintf(outfile_fd, "                ram(i_addr_a) := i_data_a;\n");
    fprintf(outfile_fd, "            end if;\n");
    fprintf(outfile_fd, "            o_q_a <= ram(i_addr_a);\n");
    fprintf(outfile_fd, "        end if;\n");
    fprintf(outfile_fd, "    end process;\n");
    fprintf(outfile_fd, "    \n");
    fprintf(outfile_fd, "    -- Port B\n");
    fprintf(outfile_fd, "    process(i_clk_b)\n");
    fprintf(outfile_fd, "    begin\n");
    fprintf(outfile_fd, "        if(rising_edge(i_clk_b)) then\n");
    fprintf(outfile_fd, "            if(i_we_b = '1') then\n");
    fprintf(outfile_fd, "                ram(i_addr_b) := i_data_b;\n");
    fprintf(outfile_fd, "            end if;\n");
    fprintf(outfile_fd, "            o_q_b <= ram(i_addr_b);\n");
    fprintf(outfile_fd, "        end if;\n");
    fprintf(outfile_fd, "    end process;\n");
    fprintf(outfile_fd, "end rtl;\n");


    exit(EXIT_SUCCESS);
}