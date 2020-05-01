using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CamMove : MonoBehaviour
{
    // Start is called before the first frame update
    float speed = 5;
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (Input.mousePosition.x >= Screen.width - 100)
        {
            transform.Translate(new Vector3(speed * Time.deltaTime, 0, 0));
        }
        if (Input.mousePosition.x <= 100)
        {
            transform.Translate(new Vector3(-speed * Time.deltaTime, 0, 0));
        }
    }

}
