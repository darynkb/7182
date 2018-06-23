using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace WindowsFormsApplication2
{
    public partial class Form1 : Form
    {
        double number_one;
        char symbol;

        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            textBox1.Text += "1";
        }

        private void button5_Click(object sender, EventArgs e)
        {
            textBox1.Text += "5";
        }

        private void button2_Click(object sender, EventArgs e)
        {
            textBox1.Text += "2";
        }

        private void button3_Click(object sender, EventArgs e)
        {
            textBox1.Text += "3";
        }

        private void button4_Click(object sender, EventArgs e)
        {
            textBox1.Text += "4";
        }

        private void button6_Click(object sender, EventArgs e)
        {
            textBox1.Text += "6";
        }

        private void button7_Click(object sender, EventArgs e)
        {
            textBox1.Text += "7";
        }

        private void button8_Click(object sender, EventArgs e)
        {
            textBox1.Text += "8";
        }

        private void button9_Click(object sender, EventArgs e)
        {
            textBox1.Text += "9";
        }

        private void button10_Click(object sender, EventArgs e)
        {
            textBox1.Text += "0";
        }
        //plus
        private void button13_Click(object sender, EventArgs e)
        {
            number_one  = Convert.ToDouble(textBox1.Text);
            symbol = '+';
            textBox1.Text = "";

        }
        // minus
        private void button14_Click(object sender, EventArgs e)
        {
            number_one  = Convert.ToDouble(textBox1.Text);
            symbol = '-';
            textBox1.Text = "";
        }
        //umnozhenie
        private void button15_Click(object sender, EventArgs e)
        {
            number_one = Convert.ToDouble(textBox1.Text);
            symbol = '*';
            textBox1.Text =  "";
        }
        //delit
        private void button16_Click(object sender, EventArgs e)
        {
            number_one = Convert.ToDouble(textBox1.Text);
            symbol = '/';
            textBox1.Text =  "";
        }

        private void button11_Click(object sender, EventArgs e)
        {
            textBox1.Text = textBox1.Text + "."; 
        }
        // ravno
        private void button12_Click(object sender, EventArgs e)
        {
            
            if( symbol == '+')
            textBox1.Text = Convert.ToString(number_one  + Convert.ToDouble(textBox1.Text));
            if (symbol == '-')
            textBox1.Text = Convert.ToString(number_one - Convert.ToDouble(textBox1.Text));
            if (symbol == '/')
                textBox1.Text = Convert.ToString(number_one / Convert.ToDouble(textBox1.Text));
            if (symbol == '*')
                textBox1.Text = Convert.ToString(number_one * Convert.ToDouble(textBox1.Text));
            if (symbol == 'C')
                textBox1.Text = textBox1.Text + " ";
        }

        private void button17_Click(object sender, EventArgs e)
        {
            number_one = Convert.ToDouble(textBox1.Text);
            symbol = 'C';
            textBox1.Text = "";
        }

		private void Form1_Load(object sender, EventArgs e)
		{

		}
	}
}
